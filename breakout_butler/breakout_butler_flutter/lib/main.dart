import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:web/web.dart' as web;

import 'core/routing/app_router.dart';
import 'core/theme/sp_theme.dart';

/// Global client for server communication.
/// Also exposed via [clientProvider] for Riverpod consumers.
late final Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Use current origin for API calls (same-origin setup with Caddy proxy)
  final serverUrl = web.window.location.origin;
  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor();

  runApp(const ProviderScope(child: BreakoutpadApp()));
}

class BreakoutpadApp extends StatelessWidget {
  const BreakoutpadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'breakoutpad',
      debugShowCheckedModeBanner: false,
      theme: buildBreakoutpadTheme(),
      routerConfig: appRouter,
    );
  }
}
