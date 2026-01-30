import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/sp_breakpoints.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_breadcrumb_nav.dart';
import '../../../core/widgets/sp_skeleton.dart';
import '../../../main.dart';
import '../../../services/cookie_web.dart';
import '../../scribe/providers/scribe_providers.dart';
import '../../session/providers/session_providers.dart';
import '../../student/widgets/room_selector.dart';
import '../widgets/content_tab.dart';
import '../widgets/dashboard_tab_bar.dart';
import '../widgets/record_button.dart';
import '../widgets/rooms_tab.dart';
import '../widgets/synthesis_dialog.dart';

/// Professor dashboard screen — three-panel layout with rooms grid
/// and transcript sidebar.
class ProfessorDashboardScreen extends ConsumerStatefulWidget {
  const ProfessorDashboardScreen({
    super.key,
    required this.urlTag,
    this.token,
  });

  final String urlTag;
  final String? token;

  @override
  ConsumerState<ProfessorDashboardScreen> createState() =>
      _ProfessorDashboardScreenState();
}

class _ProfessorDashboardScreenState
    extends ConsumerState<ProfessorDashboardScreen> {
  bool _isValidating = true;
  String? _error;
  bool _isTeacher = false;
  int? _sessionId;
  int _roomCount = 0;
  DashboardTab _currentTab = DashboardTab.content;

  @override
  void initState() {
    super.initState();
    _validateAndLoad();
  }

  Future<void> _validateAndLoad() async {
    try {
      // Load session data first (needed for both teacher and student)
      final liveSession =
          await client.session.getLiveSessionByTag(widget.urlTag);
      if (liveSession == null) {
        setState(() {
          _error = 'session not found. it may have ended.';
          _isValidating = false;
        });
        return;
      }

      final classSession =
          await client.session.getSession(liveSession.sessionId);

      // Check if user is the teacher (has valid creator token)
      final token =
          CookieService.get('creator_${widget.urlTag}') ?? widget.token;

      bool isTeacher = false;
      if (token != null && token.isNotEmpty) {
        isTeacher = await client.session.validateCreatorToken(
          widget.urlTag,
          token,
        );
      }

      // Open streaming connection for real-time updates
      await client.openStreamingConnection();

      setState(() {
        _isTeacher = isTeacher;
        _isValidating = false;
        _sessionId = liveSession.sessionId;
        _roomCount = classSession?.roomCount ?? 0;
      });
    } catch (e) {
      setState(() {
        _error = friendlyError(e);
        _isValidating = false;
      });
    }
  }

  void _onCloseRoom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('close room?', style: SpTypography.section),
        content: const Text(
          'this will close all rooms and end the session for all participants.',
          style: SpTypography.body,
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: SpColors.textSecondary,
              side: const BorderSide(color: SpColors.border),
            ),
            child: const Text('cancel'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            style: OutlinedButton.styleFrom(
              foregroundColor: SpColors.live,
              side: const BorderSide(color: SpColors.live),
            ),
            child: const Text('close'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(sessionActionsProvider.notifier).endLiveSession(
            widget.urlTag,
          );
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return const Scaffold(
        body: Center(child: SpSkeleton(width: 200, height: 24)),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SpSpacing.xl),
            child: Text(
              _error!,
              style: SpTypography.body.copyWith(color: SpColors.live),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Student view: show room selector
    if (!_isTeacher) {
      return Scaffold(
        body: Column(
          children: [
            SpBreadcrumbNav(
              segments: ['breakoutpad', widget.urlTag],
              onSegmentTap: (index) {
                if (index == 0) context.go('/');
              },
            ),
            Expanded(
              child: RoomSelector(
                urlTag: widget.urlTag,
                roomCount: _roomCount,
              ),
            ),
          ],
        ),
      );
    }

    // Teacher view: professor dashboard
    final isMobile = screenSizeOf(context) == SpScreenSize.mobile;

    return Scaffold(
      body: Column(
        children: [
          // ── Nav bar ────────────────────────────────────────────────
          SpBreadcrumbNav(
            segments: ['breakoutpad', widget.urlTag],
            onSegmentTap: (index) {
              if (index == 0) context.go('/');
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_currentTab == DashboardTab.rooms)
                  Padding(
                    padding: const EdgeInsets.only(right: SpSpacing.sm),
                    child: _SynthesizeButton(sessionId: _sessionId!, compact: isMobile),
                  ),
                RecordButton(sessionId: _sessionId!, compact: isMobile),
                const SizedBox(width: SpSpacing.sm),
                OutlinedButton(
                  onPressed: _onCloseRoom,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SpColors.live,
                    side: const BorderSide(color: SpColors.border),
                  ),
                  child: isMobile
                      ? const Icon(Icons.close, size: 16)
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, size: 16),
                            SizedBox(width: 8),
                            Text('close room'),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // ── Tab bar ────────────────────────────────────────────────
          DashboardTabBar(
            currentTab: _currentTab,
            onChanged: (tab) => setState(() => _currentTab = tab),
          ),

          // ── Tab content ────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _currentTab == DashboardTab.content ? 0 : 1,
              children: [
                ContentTab(sessionId: _sessionId!),
                RoomsTab(
                  sessionId: _sessionId!,
                  roomCount: _roomCount,
                  urlTag: widget.urlTag,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Synthesize button that shows in nav header on rooms tab.
class _SynthesizeButton extends ConsumerWidget {
  const _SynthesizeButton({required this.sessionId, this.compact = false});

  final int sessionId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scribeState = ref.watch(scribeActionsProvider);

    final icon = scribeState.isSynthesizing
        ? const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.auto_awesome, size: 16);

    final onPressed = scribeState.isSynthesizing
        ? null
        : () async {
            final response = await ref
                .read(scribeActionsProvider.notifier)
                .synthesizeAllRooms(sessionId);
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (_) => SynthesisDialog(result: response.answer),
              );
            }
          };

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: SpColors.aiAccent,
        side: const BorderSide(color: SpColors.border),
      ),
      child: compact
          ? icon
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 8),
                const Text('synthesize'),
              ],
            ),
    );
  }
}
