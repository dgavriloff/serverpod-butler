import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/professor_dashboard.dart';
import 'screens/student_room.dart';

/// Global client for server communication
late final Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get server URL from config or default to localhost
  final serverUrl = await getServerUrl();

  client = Client(serverUrl)..connectivityMonitor = FlutterConnectivityMonitor();

  runApp(const BreakoutButlerApp());
}

class BreakoutButlerApp extends StatelessWidget {
  const BreakoutButlerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breakout Butler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');
    final pathSegments = uri.pathSegments;

    // Route: / - Home screen (create session)
    if (pathSegments.isEmpty) {
      return MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: settings,
      );
    }

    // Route: /:urlTag - Professor dashboard
    // Route: /:urlTag/:roomNumber - Student room
    if (pathSegments.length == 1) {
      final urlTag = pathSegments[0];
      return MaterialPageRoute(
        builder: (_) => ProfessorDashboard(urlTag: urlTag),
        settings: settings,
      );
    }

    if (pathSegments.length == 2) {
      final urlTag = pathSegments[0];
      final roomNumber = int.tryParse(pathSegments[1]);
      if (roomNumber != null) {
        return MaterialPageRoute(
          builder: (_) => StudentRoom(urlTag: urlTag, roomNumber: roomNumber),
          settings: settings,
        );
      }
    }

    // Fallback to home
    return MaterialPageRoute(
      builder: (_) => const HomeScreen(),
      settings: settings,
    );
  }
}
