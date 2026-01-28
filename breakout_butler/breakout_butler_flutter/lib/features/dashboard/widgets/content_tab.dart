import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/sp_breakpoints.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_button.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../../core/widgets/sp_text_field.dart';
import '../../../main.dart';
import '../../transcript/providers/recording_providers.dart';
import '../../transcript/providers/transcript_providers.dart';

/// Content tab: two-column layout with prompt (left) and transcript (right).
class ContentTab extends ConsumerStatefulWidget {
  const ContentTab({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends ConsumerState<ContentTab> {
  final _promptController = TextEditingController();
  final _transcriptController = TextEditingController();
  bool _isExtracting = false;

  @override
  void dispose() {
    _promptController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _pullFromTranscript() async {
    setState(() => _isExtracting = true);
    try {
      // Sync local transcript to server first
      final transcriptText = _transcriptController.text.trim();
      if (transcriptText.isNotEmpty) {
        await client.butler.setTranscript(widget.sessionId, transcriptText);
      }

      final result = await client.butler.extractAssignment(widget.sessionId);
      if (result != null && mounted) {
        _promptController.text = result;
      }
    } finally {
      if (mounted) setState(() => _isExtracting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transcriptState =
        ref.watch(transcriptStateProvider(widget.sessionId));
    final recordingState =
        ref.watch(recordingControllerProvider(widget.sessionId));
    final screenSize = screenSizeOf(context);
    final isWide = screenSize != SpScreenSize.mobile;

    // Sync transcript controller when not recording and chunks change
    if (!recordingState.isRecording) {
      final fullText = transcriptState.fullText;
      if (_transcriptController.text != fullText) {
        _transcriptController.text = fullText;
      }
    }

    // Two-column on tablet/desktop, stacked on mobile
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Prompt
          Expanded(
            flex: 1,
            child: _buildPromptSection(transcriptState.hasContent),
          ),
          const VerticalDivider(width: 1),
          // Right column: Transcript
          Expanded(
            flex: 1,
            child: _buildTranscriptSection(
              transcriptState,
              recordingState.isRecording,
            ),
          ),
        ],
      );
    }

    // Mobile: stacked
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromptSection(transcriptState.hasContent),
          const SizedBox(height: SpSpacing.lg),
          SizedBox(
            height: 400,
            child: _buildTranscriptSection(
              transcriptState,
              recordingState.isRecording,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSection(bool hasTranscript) {
    final canPull = hasTranscript && !_isExtracting;

    return Padding(
      padding: const EdgeInsets.all(SpSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with button
          Row(
            children: [
              SpHighlight(
                child: Text('prompt', style: SpTypography.section),
              ),
              const Spacer(),
              SpSecondaryButton(
                label: 'pull from transcript',
                icon: Icons.auto_awesome,
                isLoading: _isExtracting,
                onPressed: canPull ? _pullFromTranscript : null,
              ),
            ],
          ),
          const SizedBox(height: SpSpacing.xs),
          Text(
            'context for the breakout session',
            style: SpTypography.caption.copyWith(color: SpColors.textTertiary),
          ),
          const SizedBox(height: SpSpacing.md),
          SpTextField(
            controller: _promptController,
            hint: 'what should students work on?',
            maxLines: 8,
            minLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptSection(
    TranscriptState transcriptState,
    bool isRecording,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(SpSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SpHighlight(
                    child: Text('transcript', style: SpTypography.section),
                  ),
                  if (isRecording) ...[
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
                isRecording
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
          child: isRecording
              ? _buildLiveTranscript(transcriptState)
              : _buildEditableTranscript(),
        ),
      ],
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
      padding: const EdgeInsets.all(SpSpacing.md),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpSpacing.md),
      child: TextField(
        controller: _transcriptController,
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
          contentPadding: const EdgeInsets.all(SpSpacing.md),
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
