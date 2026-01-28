import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_empty_state.dart';
import '../../transcript/providers/transcript_providers.dart';

/// Scrollable list of transcript chunks from the lecture.
///
/// Shown in the scribe sidebar to give context for questions.
class LectureContext extends ConsumerWidget {
  const LectureContext({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transcriptState = ref.watch(transcriptStateProvider(sessionId));
    final chunks = transcriptState.chunks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpSpacing.md,
            vertical: SpSpacing.sm,
          ),
          child: Text(
            'FROM THE LECTURE:',
            style: SpTypography.overline.copyWith(
              color: SpColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: chunks.isEmpty
              ? const SpEmptyState(
                  icon: Icons.hearing,
                  message: 'no transcript yet.\nstart recording to see lecture context.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpSpacing.md,
                    vertical: SpSpacing.sm,
                  ),
                  itemCount: chunks.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: SpSpacing.xs),
                  itemBuilder: (context, index) {
                    return Text(
                      chunks[index],
                      style: SpTypography.caption.copyWith(
                        color: SpColors.textSecondary,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
