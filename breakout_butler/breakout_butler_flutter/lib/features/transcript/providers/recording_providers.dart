import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';
import '../../../services/audio_recorder_web.dart';
import '../../../services/speech_recognition_web.dart';
import 'transcript_providers.dart';

/// Controls microphone recording + speech recognition.
///
/// Wraps AudioRecorderService + SpeechRecognitionService.
/// Manages: isRecording, usingSpeechApi, interimText.
class RecordingControllerNotifier extends StateNotifier<RecordingState> {
  RecordingControllerNotifier(this._ref, this._sessionId)
      : super(const RecordingState());

  final Ref _ref;
  final int _sessionId;

  AudioRecorderService? _audioRecorder;
  SpeechRecognitionService? _speechService;
  StreamSubscription? _speechSub;
  StreamSubscription? _audioChunkSub;
  final List<Uint8List> _audioQueue = [];
  bool _isProcessingQueue = false;

  /// The audio level stream for the visualizer.
  Stream<List<double>>? get audioLevelStream => _audioRecorder?.audioLevelStream;

  Future<void> toggle() async {
    if (state.isRecording) {
      await _stop();
    } else {
      await _start();
    }
  }

  Future<void> _start() async {
    final useSpeechApi = SpeechRecognitionService.isSupported;

    // Only Chrome has reliable speech recognition - show error for other browsers
    if (!useSpeechApi) {
      state = state.copyWith(
        error: 'Voice transcription is only supported in Google Chrome.',
      );
      return;
    }

    _audioRecorder = AudioRecorderService();
    final error = await _audioRecorder!.startRecording(
      enableRecorder: false, // Always use speech API when supported
    );

    if (error != null) {
      state = state.copyWith(error: error);
      return;
    }

    state = state.copyWith(
      isRecording: true,
      usingSpeechApi: true,
      error: null,
    );

    _startSpeechRecognition();
  }

  void _startSpeechRecognition() {
    _speechService = SpeechRecognitionService();
    _speechService!.start();

    _speechSub = _speechService!.resultStream.listen((result) {
      if (!mounted) return;

      final transcriptNotifier =
          _ref.read(transcriptStateProvider(_sessionId).notifier);

      if (result.isFinal) {
        transcriptNotifier.clearInterimText();
        if (result.text.trim().isNotEmpty) {
          client.butler.addTranscriptText(_sessionId, result.text);
        }
      } else {
        transcriptNotifier.setInterimText(result.text);
      }
    });
  }

  void _startAudioChunkProcessing() {
    _audioChunkSub = _audioRecorder!.audioStream.listen((chunk) {
      _audioQueue.add(chunk);
      _processQueue();
    });
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue || _audioQueue.isEmpty) return;
    _isProcessingQueue = true;

    while (_audioQueue.isNotEmpty) {
      final chunk = _audioQueue.removeAt(0);
      try {
        await client.butler.processAudio(
          _sessionId,
          ByteData.sublistView(chunk),
          'audio/webm;codecs=opus',
        );
      } catch (_) {
        // Continue processing remaining chunks
      }
    }

    _isProcessingQueue = false;
  }

  Future<void> _stop() async {
    // Flush interim text from speech API
    if (state.usingSpeechApi && _speechService != null) {
      final transcriptNotifier =
          _ref.read(transcriptStateProvider(_sessionId).notifier);
      final interim =
          _ref.read(transcriptStateProvider(_sessionId)).interimText;
      if (interim.trim().isNotEmpty) {
        client.butler.addTranscriptText(_sessionId, interim);
      }
      transcriptNotifier.clearInterimText();
      _speechService!.stop();
    }

    _speechSub?.cancel();
    _audioChunkSub?.cancel();
    await _audioRecorder?.stopRecording();

    _speechService = null;
    _audioRecorder = null;

    if (mounted) {
      state = state.copyWith(isRecording: false);
    }
  }

  @override
  void dispose() {
    _speechSub?.cancel();
    _audioChunkSub?.cancel();
    _audioRecorder?.stopRecording();
    _speechService?.stop();
    super.dispose();
  }
}

class RecordingState {
  const RecordingState({
    this.isRecording = false,
    this.usingSpeechApi = false,
    this.error,
  });

  final bool isRecording;
  final bool usingSpeechApi;
  final String? error;

  RecordingState copyWith({
    bool? isRecording,
    bool? usingSpeechApi,
    String? error,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      usingSpeechApi: usingSpeechApi ?? this.usingSpeechApi,
      error: error,
    );
  }
}

final recordingControllerProvider = StateNotifierProvider.autoDispose
    .family<RecordingControllerNotifier, RecordingState, int>(
  (ref, sessionId) => RecordingControllerNotifier(ref, sessionId),
);
