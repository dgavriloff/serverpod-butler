import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';

/// Provider to fetch and cache the prompt for a session.
final promptProvider =
    FutureProvider.autoDispose.family<String, int>((ref, sessionId) async {
  return await client.butler.getPrompt(sessionId);
});
