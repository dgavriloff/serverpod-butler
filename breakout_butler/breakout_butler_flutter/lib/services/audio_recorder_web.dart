import 'dart:async';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'dart:math' as math;
import 'package:web/web.dart' as web;

/// Audio recorder service for web platform using MediaRecorder API
class AudioRecorderService {
  web.MediaRecorder? _mediaRecorder;
  web.MediaStream? _mediaStream;
  final List<web.Blob> _audioChunks = [];
  bool _isRecording = false;

  // Audio analysis for visualizer
  web.AudioContext? _audioContext;
  web.AnalyserNode? _analyserNode;
  web.MediaStreamAudioSourceNode? _sourceNode;
  Timer? _levelTimer;
  final StreamController<List<double>> _audioLevelController =
      StreamController<List<double>>.broadcast();

  final StreamController<Uint8List> _audioStreamController = StreamController<Uint8List>.broadcast();

  /// Stream of audio chunks as they're recorded
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  /// Stream of audio levels (list of 10 normalized doubles 0.0–1.0) for visualizer
  Stream<List<double>> get audioLevelStream => _audioLevelController.stream;

  /// Whether recording is currently active
  bool get isRecording => _isRecording;

  /// Start recording from microphone
  /// Returns error message string on failure, null on success
  Future<String?> startRecording() async {
    print('[AudioRecorder] startRecording called');
    try {
      final location = web.window.location;
      final isSecure = location.protocol == 'https:' ||
                       location.hostname == 'localhost' ||
                       location.hostname == '127.0.0.1';
      print('[AudioRecorder] protocol=${location.protocol}, hostname=${location.hostname}, isSecure=$isSecure');

      if (!isSecure) {
        return 'Microphone access requires HTTPS or localhost. '
               'Please access the app via localhost on the server machine, '
               'or set up HTTPS.';
      }

      // Request microphone access
      print('[AudioRecorder] requesting getUserMedia...');
      final constraints = web.MediaStreamConstraints(
        audio: true.toJS,
        video: false.toJS,
      );
      _mediaStream = await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
      print('[AudioRecorder] got MediaStream, tracks=${_mediaStream!.getTracks().toDart.length}');

      // Create MediaRecorder
      final options = web.MediaRecorderOptions(
        mimeType: 'audio/webm;codecs=opus',
      );
      _mediaRecorder = web.MediaRecorder(_mediaStream!, options);
      _audioChunks.clear();
      print('[AudioRecorder] MediaRecorder created, state=${_mediaRecorder!.state}');

      // Handle data available event
      _mediaRecorder!.ondataavailable = (web.BlobEvent event) {
        print('[AudioRecorder] ondataavailable: ${event.data.size} bytes');
        if (event.data.size > 0) {
          _audioChunks.add(event.data);
          _processChunk(event.data);
        }
      }.toJS;

      // Set up audio analysis for visualizer
      print('[AudioRecorder] creating AudioContext...');
      _audioContext = web.AudioContext();
      print('[AudioRecorder] AudioContext state=${_audioContext!.state}, sampleRate=${_audioContext!.sampleRate}');
      if (_audioContext!.state == 'suspended') {
        print('[AudioRecorder] resuming suspended AudioContext...');
        await _audioContext!.resume().toDart;
        print('[AudioRecorder] AudioContext resumed, state=${_audioContext!.state}');
      }

      _analyserNode = _audioContext!.createAnalyser();
      _analyserNode!.fftSize = 256;
      _analyserNode!.smoothingTimeConstant = 0.4;
      _analyserNode!.minDecibels = -90;
      _analyserNode!.maxDecibels = -10;
      print('[AudioRecorder] AnalyserNode created: fftSize=${_analyserNode!.fftSize}, frequencyBinCount=${_analyserNode!.frequencyBinCount}');

      // Store source node as field to prevent GC in WASM
      _sourceNode = _audioContext!.createMediaStreamSource(_mediaStream!);
      _sourceNode!.connect(_analyserNode!);
      print('[AudioRecorder] source -> analyser connected');

      // Periodically read frequency data and emit normalized levels
      _levelTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
        _emitAudioLevels();
      });
      print('[AudioRecorder] level timer started (60ms interval)');

      // Start recording with timeslice (emit data every 3 seconds)
      _mediaRecorder!.start(3000);
      _isRecording = true;
      print('[AudioRecorder] recording started, state=${_mediaRecorder!.state}');

      return null; // Success
    } catch (e, st) {
      print('[AudioRecorder] startRecording ERROR: $e');
      print('[AudioRecorder] STACK: $st');
      final errorStr = e.toString();
      if (errorStr.contains('NotAllowedError') || errorStr.contains('Permission')) {
        return 'Microphone permission denied. Please allow microphone access in your browser settings.';
      } else if (errorStr.contains('NotFoundError')) {
        return 'No microphone found. Please connect a microphone and try again.';
      }
      return 'Failed to start recording: $e';
    }
  }

  /// Process audio chunk and emit to stream
  Future<void> _processChunk(web.Blob blob) async {
    try {
      final arrayBuffer = await blob.arrayBuffer().toDart;
      final bytes = arrayBuffer.toDart.asUint8List();
      _audioStreamController.add(bytes);
    } catch (e) {
      print('Error processing chunk: $e');
    }
  }

  /// Stop recording
  Future<Uint8List?> stopRecording() async {
    if (_mediaRecorder == null || !_isRecording) return null;

    final completer = Completer<Uint8List?>();

    _mediaRecorder!.onstop = (web.Event event) {
      _isRecording = false;

      // Combine all chunks into single blob
      if (_audioChunks.isNotEmpty) {
        final combinedBlob = web.Blob(
          _audioChunks.toJS,
          web.BlobPropertyBag(type: 'audio/webm'),
        );

        // Use Future to handle async operation without making callback async
        combinedBlob.arrayBuffer().toDart.then((arrayBuffer) {
          final bytes = arrayBuffer.toDart.asUint8List();
          completer.complete(bytes);
        }).catchError((e) {
          completer.complete(null);
        });
      } else {
        completer.complete(null);
      }

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

      // Clean up
      _mediaStream?.getTracks().toDart.forEach((track) => track.stop());
      _mediaStream = null;
      _mediaRecorder = null;
      _audioChunks.clear();
    }.toJS;

    _mediaRecorder!.stop();

    return completer.future;
  }

  int _emitCount = 0;

  /// Emit normalized audio levels from the analyser node
  void _emitAudioLevels() {
    if (_analyserNode == null) {
      if (_emitCount == 0) print('[AudioRecorder] _emitAudioLevels: analyserNode is null!');
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

    // Also track raw max for debugging
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

    // Log every 16th emission (~1/sec)
    _emitCount++;
    if (_emitCount % 16 == 1) {
      final levelsStr = levels.map((l) => l.toStringAsFixed(2)).join(', ');
      print('[AudioRecorder] levels[$_emitCount]: rawMax=$rawMax [$levelsStr]');
    }

    _audioLevelController.add(levels);
  }

  /// Dispose resources
  void dispose() {
    _levelTimer?.cancel();
    if (_isRecording) {
      stopRecording();
    }
    _audioStreamController.close();
    _audioLevelController.close();
  }
}
