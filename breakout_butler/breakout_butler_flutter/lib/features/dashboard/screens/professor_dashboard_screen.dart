import 'package:breakout_butler_client/breakout_butler_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/error_utils.dart';
import '../../../core/layout/sp_breakpoints.dart';
import '../../../core/layout/sp_three_panel_layout.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_ai_card.dart';
import '../../../core/widgets/sp_breadcrumb_nav.dart';
import '../../../core/widgets/sp_skeleton.dart';
import '../../../main.dart';
import '../../../services/cookie_web.dart';
import '../../session/providers/session_providers.dart';
import '../../transcript/widgets/mobile_transcript_bar.dart';
import '../../transcript/widgets/transcript_panel.dart';
import '../widgets/dashboard_action_bar.dart';
import '../widgets/room_detail_sheet.dart';
import '../widgets/rooms_grid.dart';

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
  bool _tokenValid = false;
  int? _sessionId;
  int _roomCount = 0;
  String? _synthesisResult;

  @override
  void initState() {
    super.initState();
    _validateAndLoad();
  }

  Future<void> _validateAndLoad() async {
    try {
      // Resolve creator token: cookie first, then URL query param fallback
      final token =
          CookieService.get('creator_${widget.urlTag}') ?? widget.token;

      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'access denied. no creator token found.';
          _isValidating = false;
        });
        return;
      }

      final isValid = await client.session.validateCreatorToken(
        widget.urlTag,
        token,
      );
      if (!isValid) {
        setState(() {
          _error = 'access denied. invalid creator token.';
          _isValidating = false;
        });
        return;
      }

      // Token valid — now load session data
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

      // Open streaming connection for real-time updates
      await client.openStreamingConnection();

      setState(() {
        _tokenValid = true;
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('close',
                style: SpTypography.body.copyWith(color: SpColors.live)),
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

  void _onRoomTap(int roomNumber, String content) {
    showDialog(
      context: context,
      builder: (_) => RoomDetailSheet(
        sessionId: _sessionId!,
        roomNumber: roomNumber,
        content: content,
      ),
    );
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

    final screenSize = screenSizeOf(context);

    return SpThreePanelLayout(
      nav: SpBreadcrumbNav(
        segments: ['breakoutpad', widget.urlTag],
        onSegmentTap: (index) {
          if (index == 0) context.go('/');
        },
        trailing: OutlinedButton.icon(
          onPressed: _onCloseRoom,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('close room'),
          style: OutlinedButton.styleFrom(
            foregroundColor: SpColors.live,
            side: const BorderSide(color: SpColors.border),
          ),
        ),
      ),
      body: Column(
        children: [
          DashboardActionBar(
            urlTag: widget.urlTag,
            sessionId: _sessionId!,
            onSynthesisResult: (answer) {
              setState(() => _synthesisResult = answer);
            },
          ),
          if (_synthesisResult != null)
            Padding(
              padding: const EdgeInsets.all(SpSpacing.md),
              child: SpAiCard(
                header: 'synthesis',
                child: Text(_synthesisResult!, style: SpTypography.body),
              ),
            ),
          Expanded(
            child: RoomsGrid(
              sessionId: _sessionId!,
              roomCount: _roomCount,
              onRoomTap: _onRoomTap,
            ),
          ),
        ],
      ),
      sidebar: TranscriptPanel(sessionId: _sessionId!),
      mobileBottomNav: screenSize == SpScreenSize.mobile
          ? MobileTranscriptBar(
              sessionId: _sessionId!,
              onExpand: null, // handled by FAB in SpThreePanelLayout
            )
          : null,
    );
  }
}
