import 'dart:async';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Audio recorder service for web platform using MediaRecorder API
class AudioRecorderService {
  web.MediaRecorder? _mediaRecorder;
  web.MediaStream? _mediaStream;
  final List<web.Blob> _audioChunks = [];
  bool _isRecording = false;

  final StreamController<Uint8List> _audioStreamController = StreamController<Uint8List>.broadcast();

  /// Stream of audio chunks as they're recorded
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  /// Whether recording is currently active
  bool get isRecording => _isRecording;

  /// Start recording from microphone
  Future<bool> startRecording() async {
    try {
      // Request microphone access
      final constraints = web.MediaStreamConstraints(
        audio: true.toJS,
        video: false.toJS,
      );

      _mediaStream = await web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;

      // Create MediaRecorder with webm/opus format (good for speech)
      final options = web.MediaRecorderOptions(
        mimeType: 'audio/webm;codecs=opus',
      );

      _mediaRecorder = web.MediaRecorder(_mediaStream!, options);
      _audioChunks.clear();

      // Handle data available event
      _mediaRecorder!.ondataavailable = (web.BlobEvent event) {
        if (event.data.size > 0) {
          _audioChunks.add(event.data);
          _processChunk(event.data);
        }
      }.toJS;

      // Start recording with timeslice (emit data every 3 seconds)
      _mediaRecorder!.start(3000);
      _isRecording = true;

      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
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

      // Clean up
      _mediaStream?.getTracks().toDart.forEach((track) => track.stop());
      _mediaStream = null;
      _mediaRecorder = null;
      _audioChunks.clear();
    }.toJS;

    _mediaRecorder!.stop();

    return completer.future;
  }

  /// Dispose resources
  void dispose() {
    if (_isRecording) {
      stopRecording();
    }
    _audioStreamController.close();
  }
}
