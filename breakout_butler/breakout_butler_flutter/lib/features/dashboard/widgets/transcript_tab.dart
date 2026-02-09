import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpSpacing.lg,
                  vertical: SpSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        isActive ? SpHighlight(child: headerText) : headerText,
                        if (recordingState.isRecording) ...[
                          const SizedBox(width: SpSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SpColors.live.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'recording',
                              style: SpTypography.caption.copyWith(
                                color: SpColors.live,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: SpSpacing.xs),
                    Text(
                      recordingState.isRecording
                          ? 'listening to lecture...'
                          : 'type or record lecture content',
                      style:
                          SpTypography.caption.copyWith(color: SpColors.textTertiary),
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
