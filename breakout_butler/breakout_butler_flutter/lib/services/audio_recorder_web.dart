import 'dart:async';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'dart:math' as math;
import 'package:web/web.dart' as web;

/// Audio visualizer service for web platform.
/// Uses Web Audio API (AudioContext + AnalyserNode) to provide real-time
/// frequency data for the audio level visualizer bars.
/// Transcription is handled separately by SpeechRecognitionService.
class AudioRecorderService {
  web.MediaStream? _mediaStream;

  // Audio analysis for visualizer
  web.AudioContext? _audioContext;
  web.AnalyserNode? _analyserNode;
  web.MediaStreamAudioSourceNode? _sourceNode;
  Timer? _levelTimer;
  bool _isActive = false;

  final StreamController<List<double>> _audioLevelController =
      StreamController<List<double>>.broadcast();

  /// Stream of audio levels (list of 10 normalized doubles 0.0–1.0) for visualizer
  Stream<List<double>> get audioLevelStream => _audioLevelController.stream;

  /// Whether the visualizer is currently active
  bool get isRecording => _isActive;

  /// Start the audio visualizer (requests microphone access).
  /// Returns error message string on failure, null on success.
  Future<String?> startRecording() async {
    print('[AudioVisualizer] start called');
    try {
      final location = web.window.location;
      final isSecure = location.protocol == 'https:' ||
                       location.hostname == 'localhost' ||
                       location.hostname == '127.0.0.1';
      print('[AudioVisualizer] protocol=${location.protocol}, hostname=${location.hostname}, isSecure=$isSecure');

      if (!isSecure) {
        return 'Microphone access requires HTTPS or localhost. '
               'Please access the app via localhost on the server machine, '
               'or set up HTTPS.';
      }

      // Request microphone access
      print('[AudioVisualizer] requesting getUserMedia...');
      final constraints = web.MediaStreamConstraints(
        audio: true.toJS,
        video: false.toJS,
      );
      _mediaStream = await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
      print('[AudioVisualizer] got MediaStream, tracks=${_mediaStream!.getTracks().toDart.length}');

      // Set up audio analysis for visualizer
      print('[AudioVisualizer] creating AudioContext...');
      _audioContext = web.AudioContext();
      print('[AudioVisualizer] AudioContext state=${_audioContext!.state}, sampleRate=${_audioContext!.sampleRate}');
      if (_audioContext!.state == 'suspended') {
        print('[AudioVisualizer] resuming suspended AudioContext...');
        await _audioContext!.resume().toDart;
        print('[AudioVisualizer] AudioContext resumed, state=${_audioContext!.state}');
      }

      _analyserNode = _audioContext!.createAnalyser();
      _analyserNode!.fftSize = 256;
      _analyserNode!.smoothingTimeConstant = 0.4;
      _analyserNode!.minDecibels = -90;
      _analyserNode!.maxDecibels = -10;
      print('[AudioVisualizer] AnalyserNode created: fftSize=${_analyserNode!.fftSize}, frequencyBinCount=${_analyserNode!.frequencyBinCount}');

      // Store source node as field to prevent GC in WASM
      _sourceNode = _audioContext!.createMediaStreamSource(_mediaStream!);
      _sourceNode!.connect(_analyserNode!);
      print('[AudioVisualizer] source -> analyser connected');

      // Periodically read frequency data and emit normalized levels
      _levelTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
        _emitAudioLevels();
      });
      print('[AudioVisualizer] level timer started (60ms interval)');

      _isActive = true;
      return null; // Success
    } catch (e, st) {
      print('[AudioVisualizer] start ERROR: $e');
      print('[AudioVisualizer] STACK: $st');
      final errorStr = e.toString();
      if (errorStr.contains('NotAllowedError') || errorStr.contains('Permission')) {
        return 'Microphone permission denied. Please allow microphone access in your browser settings.';
      } else if (errorStr.contains('NotFoundError')) {
        return 'No microphone found. Please connect a microphone and try again.';
      }
      return 'Failed to start audio visualizer: $e';
    }
  }

  /// Stop the audio visualizer and release resources.
  Future<void> stopRecording() async {
    _isActive = false;

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
      if (_emitCount == 0) print('[AudioVisualizer] _emitAudioLevels: analyserNode is null!');
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
      print('[AudioVisualizer] levels[$_emitCount]: rawMax=$rawMax [$levelsStr]');
    }

    _audioLevelController.add(levels);
  }

  /// Dispose resources
  void dispose() {
    if (_isActive) {
      stopRecording();
    }
    _audioLevelController.close();
  }
}
