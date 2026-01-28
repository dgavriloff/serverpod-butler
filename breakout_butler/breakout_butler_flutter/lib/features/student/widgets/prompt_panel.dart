import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../prompt/providers/prompt_providers.dart';

/// Panel showing the professor's prompt/assignment for the breakout session.
class PromptPanel extends ConsumerWidget {
  const PromptPanel({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptAsync = ref.watch(promptProvider(sessionId));

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
                child: Text('prompt', style: SpTypography.section),
              ),
              const SizedBox(height: SpSpacing.xs),
              Text(
                'assignment from your professor',
                style:
                    SpTypography.caption.copyWith(color: SpColors.textTertiary),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Prompt content
        Expanded(
          child: promptAsync.when(
            data: (prompt) => prompt.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(SpSpacing.lg),
                      child: Text(
                        'no prompt yet.\nwait for your professor to set an assignment.',
                        style: SpTypography.caption.copyWith(
                          color: SpColors.textPlaceholder,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(SpSpacing.md),
                    child: Text(prompt, style: SpTypography.body),
                  ),
            loading: () => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Center(
              child: Text(
                'error loading prompt',
                style:
                    SpTypography.caption.copyWith(color: SpColors.textTertiary),
              ),
            ),
          ),
        ),

        // Refresh button at bottom
        Container(
          padding: const EdgeInsets.all(SpSpacing.sm),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: SpColors.border)),
          ),
          child: Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(promptProvider(sessionId)),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                'refresh',
                style: SpTypography.caption.copyWith(
                  color: SpColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
