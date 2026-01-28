import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/sp_breakpoints.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_empty_state.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../../core/widgets/sp_text_field.dart';
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
  final _manualController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _promptController.dispose();
    _manualController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addManualText() {
    final text = _manualController.text.trim();
    if (text.isEmpty) return;
    ref
        .read(transcriptStateProvider(widget.sessionId).notifier)
        .addManualText(text);
    _manualController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final transcriptState =
        ref.watch(transcriptStateProvider(widget.sessionId));
    final screenSize = screenSizeOf(context);
    final isWide = screenSize != SpScreenSize.mobile;

    // Two-column on tablet/desktop, stacked on mobile
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Prompt
          Expanded(
            flex: 1,
            child: _buildPromptSection(),
          ),
          const VerticalDivider(width: 1),
          // Right column: Transcript
          Expanded(
            flex: 1,
            child: _buildTranscriptSection(transcriptState),
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
          _buildPromptSection(),
          const SizedBox(height: SpSpacing.lg),
          SizedBox(
            height: 400,
            child: _buildTranscriptSection(transcriptState),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSection() {
    return Padding(
      padding: const EdgeInsets.all(SpSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpHighlight(
            child: Text('prompt', style: SpTypography.section),
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

  Widget _buildTranscriptSection(TranscriptState transcriptState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(SpSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SpHighlight(
                child: Text('transcript', style: SpTypography.section),
              ),
              const SizedBox(height: SpSpacing.xs),
              Text(
                'lecture content from recording or manual entry',
                style:
                    SpTypography.caption.copyWith(color: SpColors.textTertiary),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Transcript content
        Expanded(
          child: transcriptState.hasContent
              ? ListView.builder(
                  controller: _scrollController,
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
                )
              : const SpEmptyState(
                  icon: Icons.record_voice_over_outlined,
                  message: 'no transcript yet',
                ),
        ),

        // Manual input
        Container(
          padding: const EdgeInsets.all(SpSpacing.sm),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: SpColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SpTextField(
                  controller: _manualController,
                  hint: 'add text...',
                  onSubmitted: (_) => _addManualText(),
                ),
              ),
              const SizedBox(width: SpSpacing.sm),
              IconButton(
                icon: const Icon(Icons.send, size: 20),
                onPressed: _addManualText,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
