import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_skeleton.dart';
import '../../room/providers/room_providers.dart';

/// Main collaborative text editor for a student room.
///
/// Expanded multi-line text field with save indicator.
/// Reads and writes via [RoomEditorNotifier].
class CollaborativeEditor extends ConsumerStatefulWidget {
  const CollaborativeEditor({
    super.key,
    required this.sessionId,
    required this.roomNumber,
  });

  final int sessionId;
  final int roomNumber;

  @override
  ConsumerState<CollaborativeEditor> createState() =>
      _CollaborativeEditorState();
}

class _CollaborativeEditorState extends ConsumerState<CollaborativeEditor> {
  late final TextEditingController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(roomEditorProvider(
      (sessionId: widget.sessionId, roomNumber: widget.roomNumber),
    ));

    // Sync controller text from provider when remote updates arrive
    if (editorState.loaded && !_initialized) {
      _controller.text = editorState.content;
      _initialized = true;
    } else if (_initialized && editorState.content != _controller.text) {
      // Remote update — preserve cursor position
      final offset = _controller.selection.baseOffset;
      _controller.text = editorState.content;
      if (offset <= _controller.text.length) {
        _controller.selection = TextSelection.collapsed(offset: offset);
      }
    }

    if (!editorState.loaded) {
      return const Padding(
        padding: EdgeInsets.all(SpSpacing.lg),
        child: SpSkeleton(height: 200),
      );
    }

    return Column(
      children: [
        // Save indicator
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpSpacing.lg,
            vertical: SpSpacing.xs,
          ),
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: editorState.isSaving
                      ? SpColors.textPlaceholder
                      : SpColors.success,
                ),
              ),
              const SizedBox(width: SpSpacing.xs),
              Text(
                editorState.isSaving ? 'saving...' : 'saved',
                style: SpTypography.caption.copyWith(
                  color: SpColors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        // Editor
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpSpacing.md),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: SpTypography.body,
              decoration: const InputDecoration(
                hintText: 'start writing...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(SpSpacing.md),
              ),
              onChanged: (text) {
                ref
                    .read(roomEditorProvider(
                      (
                        sessionId: widget.sessionId,
                        roomNumber: widget.roomNumber,
                      ),
                    ).notifier)
                    .updateContent(text);
              },
            ),
          ),
        ),
      ],
    );
  }
}
