import 'package:breakout_butler_client/breakout_butler_client.dart';
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
      clipBehavior: Clip.none,
      children: [
        // ── Main content area ───────────────────────────────────────
        Column(
          children: [
            // Status bar (top) - occupant count left, typing indicator center, save indicator right
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpSpacing.lg,
                vertical: SpSpacing.xs,
              ),
              child: Row(
                children: [
                  // Occupant count (left) with colored dots for each user
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show colored dots for each user
                      ...editorState.presence.take(5).map((user) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _parseColor(user.color),
                              border: user.isTyping || user.isDrawing
                                  ? Border.all(
                                      color: SpColors.textPrimary, width: 1.5)
                                  : null,
                            ),
                          )),
                      if (editorState.presence.length > 5)
                        Text(
                          '+${editorState.presence.length - 5}',
                          style: SpTypography.caption.copyWith(
                            color: SpColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      const SizedBox(width: SpSpacing.xs),
                      Text(
                        '${editorState.occupantCount} here',
                        style: SpTypography.caption.copyWith(
                          color: SpColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Typing/drawing indicator (center)
                  if (editorState.otherUsers.any((u) => u.isTyping || u.isDrawing))
                    Padding(
                      padding: const EdgeInsets.only(right: SpSpacing.md),
                      child: _buildActivityIndicator(editorState.otherUsers),
                    ),
                  // Save indicator (right)
                  Row(
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
                ],
              ),
            ),

            // Layered editor: text underneath, drawing on top
            Expanded(
              child: Stack(
                children: [
                  // ── Text layer (bottom) ──────────────────────────────────
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpSpacing.md,
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        readOnly: _mode == EditorMode.draw,
                        textAlignVertical: TextAlignVertical.top,
                        style: SpTypography.body,
                        decoration: InputDecoration(
                          hintText:
                              _mode == EditorMode.write ? 'start writing...' : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(SpSpacing.md),
                        ),
                        onChanged: (text) {
                          ref
                              .read(roomEditorProvider(
                                (
                                  sessionId: widget.sessionId,
                                  roomNumber: widget.roomNumber,
                                ),
                              ).notifier)
                              .updateContent(
                                text,
                                cursorPosition: _controller.selection.baseOffset,
                              );
                        },
                      ),
                    ),
                  ),

                  // ── Drawing layer (top) ──────────────────────────────────
                  Positioned.fill(
                    child: DrawingCanvas(
                      key: _canvasKey,
                      initialData: editorState.drawingData,
                      interactive: _mode == EditorMode.draw,
                      remoteCursors: editorState.otherUsers
                          .where((u) => u.isDrawing && u.drawingX >= 0 && u.drawingY >= 0)
                          .map((u) => RemoteCursor(
                                x: u.drawingX,
                                y: u.drawingY,
                                color: u.color,
                                displayName: u.displayName,
                                isDrawing: u.isDrawing,
                              ))
                          .toList(),
                      onCursorMove: (x, y) {
                        ref
                            .read(roomEditorProvider(
                              (
                                sessionId: widget.sessionId,
                                roomNumber: widget.roomNumber,
                              ),
                            ).notifier)
                            .updateDrawingCursor(x, y);
                      },
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
                      _TextAction(
                        label: 'undo',
                        onTap:
                            _canvasKey.currentState?.hasStrokes == true
                                ? () => setState(
                                    () => _canvasKey.currentState?.undo())
                                : null,
                      ),
                      const SizedBox(width: SpSpacing.sm),
                      _TextAction(
                        label: 'clear',
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

  /// Parse a hex color string to a Color.
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return SpColors.textSecondary;
    }
  }

  /// Build an activity indicator showing who is typing/drawing.
  Widget _buildActivityIndicator(List<UserPresence> otherUsers) {
    final typingUsers = otherUsers.where((u) => u.isTyping).toList();
    final drawingUsers = otherUsers.where((u) => u.isDrawing).toList();

    String text;
    if (typingUsers.isNotEmpty && drawingUsers.isNotEmpty) {
      text = '${typingUsers.length} typing, ${drawingUsers.length} drawing';
    } else if (typingUsers.isNotEmpty) {
      final names = typingUsers.take(2).map((u) => u.displayName).join(', ');
      text = typingUsers.length > 2
          ? '$names +${typingUsers.length - 2} typing...'
          : '$names typing...';
    } else if (drawingUsers.isNotEmpty) {
      final names = drawingUsers.take(2).map((u) => u.displayName).join(', ');
      text = drawingUsers.length > 2
          ? '$names +${drawingUsers.length - 2} drawing...'
          : '$names drawing...';
    } else {
      return const SizedBox.shrink();
    }

    return Text(
      text,
      style: SpTypography.caption.copyWith(
        color: SpColors.textTertiary,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

/// Small text button for canvas undo/clear actions.
class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpSpacing.xs,
          vertical: SpSpacing.xs,
        ),
        child: Text(
          label,
          style: SpTypography.caption.copyWith(
            color: enabled ? SpColors.textSecondary : SpColors.textPlaceholder,
          ),
        ),
      ),
    );
  }
}
