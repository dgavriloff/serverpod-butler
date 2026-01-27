import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';

/// Fetch a live session by its URL tag.
final liveSessionProvider =
    FutureProvider.autoDispose.family<LiveSession?, String>(
  (ref, urlTag) => client.session.getLiveSessionByTag(urlTag),
);

/// Fetch a class session by ID.
final classSessionProvider =
    FutureProvider.autoDispose.family<ClassSession?, int>(
  (ref, sessionId) => client.session.getSession(sessionId),
);

/// Manages session creation and lifecycle actions.
class SessionActionsNotifier extends StateNotifier<AsyncValue<void>> {
  SessionActionsNotifier() : super(const AsyncValue.data(null));

  Future<ClassSession> createSession({
    required String name,
    required int roomCount,
  }) async {
    state = const AsyncValue.loading();
    try {
      final session = await client.session.createSession(name, roomCount);
      state = const AsyncValue.data(null);
      return session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<LiveSession> startLiveSession({
    required int sessionId,
    required String urlTag,
  }) async {
    state = const AsyncValue.loading();
    try {
      final live = await client.session.startLiveSession(sessionId, urlTag);
      state = const AsyncValue.data(null);
      return live;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> endLiveSession(String urlTag) async {
    state = const AsyncValue.loading();
    try {
      await client.session.endLiveSession(urlTag);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final sessionActionsProvider =
    StateNotifierProvider.autoDispose<SessionActionsNotifier, AsyncValue<void>>(
  (ref) => SessionActionsNotifier(),
);

/// Fetch all rooms for a session.
final sessionRoomsProvider =
    FutureProvider.autoDispose.family<List<Room>, int>(
  (ref, sessionId) => client.session.getRooms(sessionId),
);
