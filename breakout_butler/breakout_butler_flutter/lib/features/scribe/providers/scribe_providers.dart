import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';

/// Scribe AI actions — ask questions, summarize, synthesize.
///
/// Each action is tracked independently so multiple can be in-flight.
class ScribeActionsNotifier extends StateNotifier<ScribeActionsState> {
  ScribeActionsNotifier() : super(const ScribeActionsState());

  Future<ButlerResponse> askScribe(int sessionId, String question) async {
    state = state.copyWith(isAsking: true);
    try {
      final response = await client.butler.askButler(sessionId, question);
      state = state.copyWith(
        isAsking: false,
        lastAnswer: response,
      );
      return response;
    } catch (e) {
      state = state.copyWith(isAsking: false);
      rethrow;
    }
  }

  Future<ButlerResponse> summarizeRoom(int sessionId, int roomNumber) async {
    state = state.copyWith(isSummarizing: true);
    try {
      final response =
          await client.butler.summarizeRoom(sessionId, roomNumber);
      state = state.copyWith(isSummarizing: false);
      return response;
    } catch (e) {
      state = state.copyWith(isSummarizing: false);
      rethrow;
    }
  }

  Future<ButlerResponse> synthesizeAllRooms(int sessionId) async {
    state = state.copyWith(isSynthesizing: true);
    try {
      final response = await client.butler.synthesizeAllRooms(sessionId);
      state = state.copyWith(isSynthesizing: false);
      return response;
    } catch (e) {
      state = state.copyWith(isSynthesizing: false);
      rethrow;
    }
  }

  Future<String?> extractAssignment(int sessionId) async {
    try {
      return await client.butler.extractAssignment(sessionId);
    } catch (_) {
      return null;
    }
  }
}

class ScribeActionsState {
  const ScribeActionsState({
    this.isAsking = false,
    this.isSummarizing = false,
    this.isSynthesizing = false,
    this.lastAnswer,
  });

  final bool isAsking;
  final bool isSummarizing;
  final bool isSynthesizing;
  final ButlerResponse? lastAnswer;

  bool get isLoading => isAsking || isSummarizing || isSynthesizing;

  ScribeActionsState copyWith({
    bool? isAsking,
    bool? isSummarizing,
    bool? isSynthesizing,
    ButlerResponse? lastAnswer,
  }) {
    return ScribeActionsState(
      isAsking: isAsking ?? this.isAsking,
      isSummarizing: isSummarizing ?? this.isSummarizing,
      isSynthesizing: isSynthesizing ?? this.isSynthesizing,
      lastAnswer: lastAnswer ?? this.lastAnswer,
    );
  }
}

final scribeActionsProvider =
    StateNotifierProvider.autoDispose<ScribeActionsNotifier, ScribeActionsState>(
  (ref) => ScribeActionsNotifier(),
);
