import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_empty_state.dart';
import '../providers/transcript_providers.dart';

/// Scrollable list of transcript chunks with auto-scroll.
class TranscriptList extends ConsumerStatefulWidget {
  const TranscriptList({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<TranscriptList> createState() => _TranscriptListState();
}

class _TranscriptListState extends ConsumerState<TranscriptList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final state = ref.watch(transcriptStateProvider(widget.sessionId));

    if (!state.hasContent) {
      return const SpEmptyState(
        icon: Icons.record_voice_over_outlined,
        message: 'no transcript yet',
      );
    }

    // Auto-scroll when content changes
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    final itemCount =
        state.chunks.length + (state.interimText.isNotEmpty ? 1 : 0);

    return Semantics(
      liveRegion: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(SpSpacing.md),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index < state.chunks.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: SpSpacing.sm),
              child: Text(state.chunks[index], style: SpTypography.body),
            );
          }
          // Interim text
          return Padding(
            padding: const EdgeInsets.only(bottom: SpSpacing.sm),
            child: Text(
              state.interimText,
              style: SpTypography.body.copyWith(
                fontStyle: FontStyle.italic,
                color: SpColors.textPrimary.withValues(alpha: 0.5),
              ),
            ),
          );
        },
      ),
    );
  }
}
