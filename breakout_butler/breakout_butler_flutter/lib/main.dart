import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'core/routing/app_router.dart';
import 'core/theme/sp_theme.dart';

/// Global client for server communication.
/// Also exposed via [clientProvider] for Riverpod consumers.
late final Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final serverUrl = await getServerUrl();
  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor();

  runApp(const ProviderScope(child: ScratchpadApp()));
}

class ScratchpadApp extends StatelessWidget {
  const ScratchpadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'scratchpad',
      debugShowCheckedModeBanner: false,
      theme: buildScratchpadTheme(),
      routerConfig: appRouter,
    );
  }
}
