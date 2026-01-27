import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../screens/professor_dashboard.dart';
import '../../screens/student_room.dart';

/// scratchpad app router — declarative, URL-based.
///
/// Routes:
///   /                     → HomeScreen
///   /:urlTag              → ProfessorDashboard
///   /:urlTag/:roomNumber  → StudentRoom
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/:urlTag',
      builder: (context, state) {
        final urlTag = state.pathParameters['urlTag']!;
        final token = state.uri.queryParameters['token'];
        return ProfessorDashboard(urlTag: urlTag, token: token);
      },
      routes: [
        GoRoute(
          path: ':roomNumber',
          builder: (context, state) {
            final urlTag = state.pathParameters['urlTag']!;
            final roomNumber = int.parse(state.pathParameters['roomNumber']!);
            return StudentRoom(urlTag: urlTag, roomNumber: roomNumber);
          },
        ),
      ],
    ),
  ],
);
