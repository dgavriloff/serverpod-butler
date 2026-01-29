import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../../core/widgets/sp_markdown.dart';
import '../../prompt/providers/prompt_providers.dart';

/// Panel showing the professor's prompt/assignment for the breakout session.
class PromptPanel extends ConsumerStatefulWidget {
  const PromptPanel({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<PromptPanel> createState() => _PromptPanelState();
}

class _PromptPanelState extends ConsumerState<PromptPanel> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh prompt every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.invalidate(promptProvider(widget.sessionId));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promptAsync = ref.watch(promptProvider(widget.sessionId));

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
                    child: SpMarkdown(data: prompt),
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
      ],
    );
  }
}
