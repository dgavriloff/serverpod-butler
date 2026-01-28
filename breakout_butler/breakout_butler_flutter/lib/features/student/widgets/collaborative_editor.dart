import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_skeleton.dart';
import '../../room/providers/room_providers.dart';
import 'drawing_canvas.dart';
import 'editor_mode_selector.dart';

/// Main collaborative editor for a student room.
///
/// Supports two modes: **write** (text) and **draw** (freehand canvas).
/// A toggle in the bottom-right switches between them.
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
  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey();
  bool _initialized = false;
  EditorMode _mode = EditorMode.write;

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

    return Stack(
      children: [
        // ── Main content area ───────────────────────────────────────
        Column(
          children: [
            // Save indicator (top-right)
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

            // Editor + canvas — both kept alive via IndexedStack
            Expanded(
              child: IndexedStack(
                index: _mode == EditorMode.write ? 0 : 1,
                children: [
                  // Write mode
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpSpacing.md,
                    ),
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

                  // Draw mode
                  DrawingCanvas(
                    key: _canvasKey,
                    initialData: editorState.drawingData,
                    onChanged: (json) {
                      ref
                          .read(roomEditorProvider(
                            (
                              sessionId: widget.sessionId,
                              roomNumber: widget.roomNumber,
                            ),
                          ).notifier)
                          .updateDrawing(json);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Mode selector + draw actions (bottom-left) ──────────────
        Positioned(
          bottom: SpSpacing.sm,
          left: SpSpacing.md,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Undo / clear (only in draw mode, above selector)
              if (_mode == EditorMode.draw)
                Padding(
                  padding: const EdgeInsets.only(bottom: SpSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _IconAction(
                        icon: Icons.undo_rounded,
                        onTap:
                            _canvasKey.currentState?.hasStrokes == true
                                ? () => setState(
                                    () => _canvasKey.currentState?.undo())
                                : null,
                      ),
                      const SizedBox(width: SpSpacing.xs),
                      _IconAction(
                        icon: Icons.delete_forever_rounded,
                        onTap:
                            _canvasKey.currentState?.hasStrokes == true
                                ? () => setState(
                                    () => _canvasKey.currentState?.clear())
                                : null,
                      ),
                    ],
                  ),
                ),

              // Write / draw toggle
              EditorModeSelector(
                currentMode: _mode,
                onChanged: (mode) => setState(() => _mode = mode),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small icon button for canvas undo/clear actions.
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(SpSpacing.xs),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? SpColors.textSecondary : SpColors.textPlaceholder,
        ),
      ),
    );
  }
}
