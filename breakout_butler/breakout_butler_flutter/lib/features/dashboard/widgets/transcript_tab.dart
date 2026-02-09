import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/sp_breakpoints.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_radius.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../transcript/providers/recording_providers.dart';
import '../../transcript/providers/transcript_providers.dart';

/// Transcript tab: full-width transcript editor/viewer.
class TranscriptTab extends ConsumerStatefulWidget {
  const TranscriptTab({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<TranscriptTab> createState() => _TranscriptTabState();
}

class _TranscriptTabState extends ConsumerState<TranscriptTab> {
  final _transcriptController = TextEditingController();
  final _transcriptFocusNode = FocusNode();
  bool _transcriptHovered = false;
  bool _transcriptFocused = false;

  @override
  void initState() {
    super.initState();
    _transcriptFocusNode.addListener(_onTranscriptFocusChange);
  }

  void _onTranscriptFocusChange() {
    setState(() => _transcriptFocused = _transcriptFocusNode.hasFocus);
  }

  @override
  void dispose() {
    _transcriptFocusNode.removeListener(_onTranscriptFocusChange);
    _transcriptController.dispose();
    _transcriptFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transcriptState =
        ref.watch(transcriptStateProvider(widget.sessionId));
    final recordingState =
        ref.watch(recordingControllerProvider(widget.sessionId));

    // Sync transcript controller when not recording and chunks change
    if (!recordingState.isRecording) {
      final fullText = transcriptState.fullText;
      if (_transcriptController.text != fullText) {
        _transcriptController.text = fullText;
      }
    }

    // When recording, always show highlight (it's active)
    final isActive =
        recordingState.isRecording || _transcriptHovered || _transcriptFocused;
    final headerText = Text('transcript', style: SpTypography.section);
    final screenSize = screenSizeOf(context);
    final isWide = screenSize != SpScreenSize.mobile;

    // Show error as snackbar when it changes
    ref.listen<RecordingState>(
      recordingControllerProvider(widget.sessionId),
      (previous, next) {
        if (next.error != null && next.error != previous?.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpSpacing.lg),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: SpColors.surface,
            borderRadius: BorderRadius.circular(SpRadius.card),
            boxShadow: [
              BoxShadow(
                color: SpColors.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpSpacing.lg,
                  vertical: SpSpacing.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isActive ? SpHighlight(child: headerText) : headerText,
                          const SizedBox(height: SpSpacing.xs),
                          Text(
                            recordingState.isRecording
                                ? 'listening to lecture...'
                                : 'type or record lecture content',
                            style: SpTypography.caption
                                .copyWith(color: SpColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    _RecordButton(
                      isRecording: recordingState.isRecording,
                      iconOnly: !isWide,
                      onPressed: () => ref
                          .read(recordingControllerProvider(widget.sessionId).notifier)
                          .toggle(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Transcript content - editable when not recording
              Expanded(
                child: recordingState.isRecording
                    ? _buildLiveTranscript(transcriptState)
                    : _buildEditableTranscript(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveTranscript(TranscriptState transcriptState) {
    if (!transcriptState.hasContent) {
      return Center(
        child: Text(
          'waiting for speech...',
          style: SpTypography.caption.copyWith(color: SpColors.textPlaceholder),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: SpSpacing.lg,
        vertical: SpSpacing.md,
      ),
      itemCount: transcriptState.chunks.length +
          (transcriptState.interimText.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < transcriptState.chunks.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: SpSpacing.sm),
            child: Text(
              transcriptState.chunks[index],
              style: SpTypography.body,
            ),
          );
        }
        // Interim text
        return Text(
          transcriptState.interimText,
          style: SpTypography.body.copyWith(
            fontStyle: FontStyle.italic,
            color: SpColors.textTertiary,
          ),
        );
      },
    );
  }

  Widget _buildEditableTranscript() {
    return MouseRegion(
      onEnter: (_) => setState(() => _transcriptHovered = true),
      onExit: (_) => setState(() => _transcriptHovered = false),
      child: TextField(
        controller: _transcriptController,
        focusNode: _transcriptFocusNode,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: SpTypography.body,
        decoration: InputDecoration(
          hintText: 'paste or type lecture content here...',
          hintStyle:
              SpTypography.body.copyWith(color: SpColors.textPlaceholder),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SpSpacing.lg,
            vertical: SpSpacing.md,
          ),
        ),
        onChanged: (text) {
          // Update transcript state when user edits
          ref
              .read(transcriptStateProvider(widget.sessionId).notifier)
              .setFullText(text);
        },
      ),
    );
  }
}

/// Record button styled like SpSecondaryButton.
class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.isRecording,
    required this.onPressed,
    this.iconOnly = false,
  });

  final bool isRecording;
  final VoidCallback onPressed;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    if (isRecording) {
      // Recording state: red styling with blinking dot
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: SpColors.live,
          side: const BorderSide(color: SpColors.live),
        ),
        child: iconOnly
            ? const _BlinkingDot()
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BlinkingDot(),
                  SizedBox(width: 8),
                  Text('stop', style: TextStyle(height: 1.0)),
                ],
              ),
      );
    }

    // Not recording: normal styling with mic icon
    return OutlinedButton(
      onPressed: onPressed,
      child: iconOnly
          ? const Icon(Icons.mic_none, size: 16)
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic_none, size: 16),
                SizedBox(width: 8),
                Text('record', style: TextStyle(height: 1.0)),
              ],
            ),
    );
  }
}

/// Blinking red dot indicator for recording state.
class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: SpColors.live,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
