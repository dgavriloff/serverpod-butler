import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_card.dart';
import '../../../core/widgets/sp_empty_state.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../../core/widgets/sp_text_field.dart';
import '../../transcript/providers/transcript_providers.dart';

/// Content tab: prompt/context setup + transcript display.
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final transcriptState =
        ref.watch(transcriptStateProvider(widget.sessionId));

    // Auto-scroll when transcript changes
    if (transcriptState.hasContent) {
      _scrollToBottom();
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(SpSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Prompt Section ─────────────────────────────────────────
          SpHighlight(
            child: Text('prompt', style: SpTypography.section),
          ),
          const SizedBox(height: SpSpacing.sm),
          Text(
            'give your students context for the breakout session',
            style: SpTypography.caption.copyWith(color: SpColors.textTertiary),
          ),
          const SizedBox(height: SpSpacing.md),
          SpCard(
            child: SpTextField(
              controller: _promptController,
              hint: 'what should students work on?',
              maxLines: 4,
            ),
          ),

          const SizedBox(height: SpSpacing.xl),

          // ── Transcript Section ─────────────────────────────────────
          SpHighlight(
            child: Text('transcript', style: SpTypography.section),
          ),
          const SizedBox(height: SpSpacing.sm),
          Text(
            'lecture content captured via recording or manual entry',
            style: SpTypography.caption.copyWith(color: SpColors.textTertiary),
          ),
          const SizedBox(height: SpSpacing.md),

          // Transcript content
          SpCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transcript text
                if (!transcriptState.hasContent)
                  const Padding(
                    padding: EdgeInsets.all(SpSpacing.lg),
                    child: SpEmptyState(
                      icon: Icons.record_voice_over_outlined,
                      message: 'no transcript yet. hit record to start.',
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(SpSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Finalized chunks
                        for (final chunk in transcriptState.chunks)
                          Padding(
                            padding: const EdgeInsets.only(bottom: SpSpacing.sm),
                            child: Text(chunk, style: SpTypography.body),
                          ),
                        // Interim text (currently being transcribed)
                        if (transcriptState.interimText.isNotEmpty)
                          Text(
                            transcriptState.interimText,
                            style: SpTypography.body.copyWith(
                              fontStyle: FontStyle.italic,
                              color: SpColors.textPrimary.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
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
                          hint: 'add text manually...',
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
            ),
          ),
        ],
      ),
    );
  }
}
