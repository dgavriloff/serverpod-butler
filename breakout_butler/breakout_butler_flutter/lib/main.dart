import 'dart:async';

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

/// Check if running in dev environment (hostname contains "dev" or is localhost)
bool get isDevEnvironment {
  final host = web.window.location.hostname;
  return host.contains('dev') || host == 'localhost' || host == '127.0.0.1';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Use current origin for API calls (same-origin setup with Caddy proxy)
  final serverUrl = web.window.location.origin;
  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor();

  // In production, suppress WebSocket closure errors (normal on page refresh)
  // In dev environment, let all errors surface for debugging
  if (isDevEnvironment) {
    runApp(const ProviderScope(child: BreakoutpadApp()));
  } else {
    runZonedGuarded(
      () => runApp(const ProviderScope(child: BreakoutpadApp())),
      (error, stack) {
        // Silently ignore WebSocket/streaming closure errors in production
        final errorStr = error.toString().toLowerCase();
        if (errorStr.contains('websocket') ||
            errorStr.contains('streaming') ||
            errorStr.contains('connection closed')) {
          return; // Swallow these expected errors
        }
        // Log other unexpected errors
        print('Unhandled error: $error');
      },
    );
  }
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
