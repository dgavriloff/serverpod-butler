import 'dart:async';

import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';

/// Raw stream of transcript updates for a session.
final transcriptStreamProvider =
    StreamProvider.autoDispose.family<TranscriptUpdate, int>(
  (ref, sessionId) => client.butler.transcriptStream(sessionId),
);

/// Accumulates transcript chunks from the stream + manual additions.
/// Manages interim text from speech recognition.
class TranscriptStateNotifier extends StateNotifier<TranscriptState> {
  TranscriptStateNotifier(this._sessionId) : super(const TranscriptState()) {
    _init();
  }

  final int _sessionId;
  StreamSubscription<TranscriptUpdate>? _sub;

  void _init() {
    _sub = client.butler.transcriptStream(_sessionId).listen((update) {
      if (mounted) {
        state = state.copyWith(
          chunks: [...state.chunks, update.text],
        );
      }
    });
  }

  void setInterimText(String text) {
    if (mounted) {
      state = state.copyWith(interimText: text);
    }
  }

  void clearInterimText() {
    if (mounted) {
      state = state.copyWith(interimText: '');
    }
  }

  Future<void> addManualText(String text) async {
    if (text.trim().isEmpty) return;
    await client.butler.addTranscriptText(_sessionId, text);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class TranscriptState {
  const TranscriptState({
    this.chunks = const [],
    this.interimText = '',
  });

  final List<String> chunks;
  final String interimText;

  String get fullText => chunks.join(' ');
  bool get hasContent => chunks.isNotEmpty || interimText.isNotEmpty;

  TranscriptState copyWith({
    List<String>? chunks,
    String? interimText,
  }) {
    return TranscriptState(
      chunks: chunks ?? this.chunks,
      interimText: interimText ?? this.interimText,
    );
  }
}

final transcriptStateProvider = StateNotifierProvider.autoDispose
    .family<TranscriptStateNotifier, TranscriptState, int>(
  (ref, sessionId) => TranscriptStateNotifier(sessionId),
);
