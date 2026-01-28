import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/screens/professor_dashboard_screen.dart';
import '../../features/home/screens/create_session_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/student/screens/student_room_screen.dart';

/// breakoutpad app router — declarative, URL-based.
///
/// Routes:
///   /                     → HomeScreen
///   /create               → CreateSessionScreen
///   /:urlTag              → ProfessorDashboardScreen
///   /:urlTag/:roomNumber  → StudentRoomScreen
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreateSessionScreen(),
    ),
    GoRoute(
      path: '/:urlTag',
      builder: (context, state) {
        final urlTag = state.pathParameters['urlTag']!;
        final token = state.uri.queryParameters['token'];
        return ProfessorDashboardScreen(urlTag: urlTag, token: token);
      },
      routes: [
        GoRoute(
          path: ':roomNumber',
          builder: (context, state) {
            final urlTag = state.pathParameters['urlTag']!;
            final roomNumber = int.parse(state.pathParameters['roomNumber']!);
            return StudentRoomScreen(
              urlTag: urlTag,
              roomNumber: roomNumber,
            );
          },
        ),
      ],
    ),
  ],
);
