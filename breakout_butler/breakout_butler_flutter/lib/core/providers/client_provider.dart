import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';

/// Exposes the global Serverpod [Client] via Riverpod.
///
/// The client is initialized in main() before ProviderScope,
/// so this is a simple synchronous provider.
final clientProvider = Provider<Client>((ref) => client);
