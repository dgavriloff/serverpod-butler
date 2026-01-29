import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/error_utils.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_breadcrumb_nav.dart';
import '../../../core/widgets/sp_skeleton.dart';
import '../../../main.dart';
import '../widgets/prompt_panel.dart';
import '../widgets/collaborative_editor.dart';

/// Student room screen — three-panel layout with collaborative editor
/// and scribe sidebar.
class StudentRoomScreen extends ConsumerStatefulWidget {
  const StudentRoomScreen({
    super.key,
    required this.urlTag,
    required this.roomNumber,
  });

  final String urlTag;
  final int roomNumber;

  @override
  ConsumerState<StudentRoomScreen> createState() => _StudentRoomScreenState();
}

class _StudentRoomScreenState extends ConsumerState<StudentRoomScreen> {
  bool _isLoading = true;
  String? _error;
  int? _sessionId;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final liveSession =
          await client.session.getLiveSessionByTag(widget.urlTag);
      if (liveSession == null) {
        setState(() {
          _error = 'session not found. it may have ended.';
          _isLoading = false;
        });
        return;
      }

      // Open streaming connection for real-time updates
      await client.openStreamingConnection();

      setState(() {
        _sessionId = liveSession.sessionId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = friendlyError(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
              style: SpTypography.body.copyWith(
                color: const Color(0xFFFF4444),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Nav bar
          SpBreadcrumbNav(
            segments: ['breakoutpad', widget.urlTag, 'room ${widget.roomNumber}'],
            onSegmentTap: (index) {
              if (index == 0) context.go('/');
              if (index == 1) context.go('/${widget.urlTag}');
            },
          ),

          // Two-pane layout: editor (left) + prompt (right)
          Expanded(
            child: Row(
              children: [
                // Left: Collaborative editor
                Expanded(
                  flex: 2,
                  child: CollaborativeEditor(
                    sessionId: _sessionId!,
                    roomNumber: widget.roomNumber,
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  color: SpColors.border,
                ),
                // Right: Prompt panel
                Expanded(
                  flex: 1,
                  child: PromptPanel(sessionId: _sessionId!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
