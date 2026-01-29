import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/screens/professor_dashboard_screen.dart';
import '../../features/home/screens/create_session_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/join_session_screen.dart';
import '../../features/student/screens/student_room_screen.dart';

/// Tracks the previous route depth for animation direction.
int _previousDepth = 0;

/// Returns the depth of a path (number of segments).
int _pathDepth(String path) {
  if (path == '/') return 0;
  return path.split('/').where((s) => s.isNotEmpty).length;
}

/// Custom page with directional slide transition.
/// Slides left-to-right when going deeper, right-to-left when going back.
CustomTransitionPage<void> _buildPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final currentDepth = _pathDepth(state.uri.path);
  final goingBack = currentDepth < _previousDepth;
  _previousDepth = currentDepth;

  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Going back: slide from left. Going forward: slide from right.
      final begin = goingBack ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);
      final tween = Tween(begin: begin, end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

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
      pageBuilder: (context, state) => _buildPage(
        context: context,
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/create',
      pageBuilder: (context, state) => _buildPage(
        context: context,
        state: state,
        child: const CreateSessionScreen(),
      ),
    ),
    GoRoute(
      path: '/join',
      pageBuilder: (context, state) => _buildPage(
        context: context,
        state: state,
        child: const JoinSessionScreen(),
      ),
    ),
    GoRoute(
      path: '/:urlTag',
      pageBuilder: (context, state) {
        final urlTag = state.pathParameters['urlTag']!;
        final token = state.uri.queryParameters['token'];
        return _buildPage(
          context: context,
          state: state,
          child: ProfessorDashboardScreen(urlTag: urlTag, token: token),
        );
      },
      routes: [
        GoRoute(
          path: ':roomNumber',
          pageBuilder: (context, state) {
            final urlTag = state.pathParameters['urlTag']!;
            final roomNumber = int.parse(state.pathParameters['roomNumber']!);
            return _buildPage(
              context: context,
              state: state,
              child: StudentRoomScreen(
                urlTag: urlTag,
                roomNumber: roomNumber,
              ),
            );
          },
        ),
      ],
    ),
  ],
);
