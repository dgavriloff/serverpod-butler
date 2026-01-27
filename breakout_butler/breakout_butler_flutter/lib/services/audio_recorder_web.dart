import 'dart:async';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'dart:math' as math;
import 'package:web/web.dart' as web;

/// Audio service for web platform.
/// Provides:
/// 1. Real-time frequency data for the audio level visualizer bars
///    (AudioContext + AnalyserNode).
/// 2. Optional MediaRecorder-based audio chunk capture for Gemini
///    transcription fallback (when Web Speech API is unavailable).
class AudioRecorderService {
  web.MediaStream? _mediaStream;

  // Audio analysis for visualizer
  web.AudioContext? _audioContext;
  web.AnalyserNode? _analyserNode;
  web.MediaStreamAudioSourceNode? _sourceNode;
  Timer? _levelTimer;
  bool _isActive = false;

  // MediaRecorder for Gemini fallback
  web.MediaRecorder? _mediaRecorder;
  bool _recorderEnabled = false;
  final StreamController<Uint8List> _audioStreamController =
      StreamController<Uint8List>.broadcast();

  final StreamController<List<double>> _audioLevelController =
      StreamController<List<double>>.broadcast();

  /// Stream of audio levels (list of 10 normalized doubles 0.0–1.0) for visualizer
  Stream<List<double>> get audioLevelStream => _audioLevelController.stream;

  /// Stream of audio chunks (webm/opus) for Gemini fallback transcription.
  /// Only emits data when [startRecording] is called with `enableRecorder: true`.
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  /// Whether the visualizer is currently active
  bool get isRecording => _isActive;

  /// Start the audio visualizer (requests microphone access).
  /// If [enableRecorder] is true, also starts a MediaRecorder that emits
  /// audio chunks every 3 seconds via [audioStream] (for Gemini fallback).
  /// Returns error message string on failure, null on success.
  Future<String?> startRecording({bool enableRecorder = false}) async {
    print('[AudioService] start called (enableRecorder=$enableRecorder)');
    try {
      final location = web.window.location;
      final isSecure = location.protocol == 'https:' ||
                       location.hostname == 'localhost' ||
                       location.hostname == '127.0.0.1';
      print('[AudioService] protocol=${location.protocol}, hostname=${location.hostname}, isSecure=$isSecure');

      if (!isSecure) {
        return 'Microphone access requires HTTPS or localhost. '
               'Please access the app via localhost on the server machine, '
               'or set up HTTPS.';
      }

      // Request microphone access
      print('[AudioService] requesting getUserMedia...');
      final constraints = web.MediaStreamConstraints(
        audio: true.toJS,
        video: false.toJS,
      );
      _mediaStream = await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
      print('[AudioService] got MediaStream, tracks=${_mediaStream!.getTracks().toDart.length}');

      // Set up audio analysis for visualizer
      print('[AudioService] creating AudioContext...');
      _audioContext = web.AudioContext();
      print('[AudioService] AudioContext state=${_audioContext!.state}, sampleRate=${_audioContext!.sampleRate}');
      if (_audioContext!.state == 'suspended') {
        print('[AudioService] resuming suspended AudioContext...');
        await _audioContext!.resume().toDart;
        print('[AudioService] AudioContext resumed, state=${_audioContext!.state}');
      }

      _analyserNode = _audioContext!.createAnalyser();
      _analyserNode!.fftSize = 256;
      _analyserNode!.smoothingTimeConstant = 0.4;
      _analyserNode!.minDecibels = -90;
      _analyserNode!.maxDecibels = -10;
      print('[AudioService] AnalyserNode created: fftSize=${_analyserNode!.fftSize}, frequencyBinCount=${_analyserNode!.frequencyBinCount}');

      // Store source node as field to prevent GC in WASM
      _sourceNode = _audioContext!.createMediaStreamSource(_mediaStream!);
      _sourceNode!.connect(_analyserNode!);
      print('[AudioService] source -> analyser connected');

      // Periodically read frequency data and emit normalized levels
      _levelTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
        _emitAudioLevels();
      });
      print('[AudioService] level timer started (60ms interval)');

      // Optionally start MediaRecorder for Gemini fallback
      _recorderEnabled = enableRecorder;
      if (enableRecorder) {
        _startMediaRecorder();
      }

      _isActive = true;
      return null; // Success
    } catch (e, st) {
      print('[AudioService] start ERROR: $e');
      print('[AudioService] STACK: $st');
      final errorStr = e.toString();
      if (errorStr.contains('NotAllowedError') || errorStr.contains('Permission')) {
        return 'Microphone permission denied. Please allow microphone access in your browser settings.';
      } else if (errorStr.contains('NotFoundError')) {
        return 'No microphone found. Please connect a microphone and try again.';
      }
      return 'Failed to start audio service: $e';
    }
  }

  void _startMediaRecorder() {
    if (_mediaStream == null) return;
    print('[AudioService] starting MediaRecorder...');
    try {
      _mediaRecorder = web.MediaRecorder(
        _mediaStream!,
        web.MediaRecorderOptions(mimeType: 'audio/webm;codecs=opus'),
      );
    } catch (_) {
      // Fallback mime type
      _mediaRecorder = web.MediaRecorder(_mediaStream!);
    }

    _mediaRecorder!.ondataavailable = ((web.BlobEvent event) {
      final blob = event.data;
      if (blob.size > 0) {
        _processChunk(blob);
      }
    }).toJS;

    _mediaRecorder!.start(3000); // 3-second chunks
    print('[AudioService] MediaRecorder started (3s chunks)');
  }

  Future<void> _processChunk(web.Blob blob) async {
    try {
      final reader = web.FileReader();
      final completer = Completer<Uint8List>();
      reader.onload = ((web.Event _) {
        final result = reader.result as JSArrayBuffer;
        completer.complete(result.toDart.asUint8List());
      }).toJS;
      reader.onerror = ((web.Event _) {
        completer.completeError('FileReader error');
      }).toJS;
      reader.readAsArrayBuffer(blob);
      final bytes = await completer.future;
      print('[AudioService] chunk: ${bytes.length} bytes');
      _audioStreamController.add(bytes);
    } catch (e) {
      print('[AudioService] chunk processing error: $e');
    }
  }

  /// Stop the audio service and release resources.
  Future<void> stopRecording() async {
    _isActive = false;

    // Stop MediaRecorder
    if (_mediaRecorder != null) {
      try {
        _mediaRecorder!.stop();
      } catch (_) {}
      _mediaRecorder = null;
    }
    _recorderEnabled = false;

    // Clean up audio analysis
    _levelTimer?.cancel();
    _levelTimer = null;
    _sourceNode?.disconnect();
    _sourceNode = null;
    _analyserNode?.disconnect();
    _analyserNode = null;
    if (_audioContext != null) {
      _audioContext!.close().toDart;
      _audioContext = null;
    }

    // Release microphone
    _mediaStream?.getTracks().toDart.forEach((track) => track.stop());
    _mediaStream = null;
  }

  int _emitCount = 0;

  /// Emit normalized audio levels from the analyser node
  void _emitAudioLevels() {
    if (_analyserNode == null) {
      if (_emitCount == 0) print('[AudioService] _emitAudioLevels: analyserNode is null!');
      return;
    }

    final bufferLength = _analyserNode!.frequencyBinCount;
    final jsArray = Uint8List(bufferLength).toJS;
    _analyserNode!.getByteFrequencyData(jsArray);
    final dataArray = jsArray.toDart;

    // Focus on speech-relevant bins (lower ~60% of spectrum) split into 10 bands
    const bandCount = 10;
    final usableBins = (bufferLength * 0.6).toInt();
    final bandsPerGroup = math.max(1, usableBins ~/ bandCount);
    final levels = <double>[];

    int rawMax = 0;
    for (var i = 0; i < bandCount; i++) {
      var sum = 0.0;
      final start = i * bandsPerGroup;
      final end = math.min(start + bandsPerGroup, usableBins);
      for (var j = start; j < end; j++) {
        sum += dataArray[j];
        if (dataArray[j] > rawMax) rawMax = dataArray[j];
      }
      final linear = (sum / (end - start)) / 255.0;
      levels.add(math.sqrt(linear.clamp(0.0, 1.0)));
    }

    _emitCount++;
    if (_emitCount % 16 == 1) {
      final levelsStr = levels.map((l) => l.toStringAsFixed(2)).join(', ');
      print('[AudioService] levels[$_emitCount]: rawMax=$rawMax [$levelsStr]');
    }

    _audioLevelController.add(levels);
  }

  /// Dispose resources
  void dispose() {
    if (_isActive) {
      stopRecording();
    }
    _audioLevelController.close();
    _audioStreamController.close();
  }
}
