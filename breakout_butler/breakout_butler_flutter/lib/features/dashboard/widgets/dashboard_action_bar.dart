import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_utils.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_button.dart';
import '../../scribe/providers/scribe_providers.dart';

/// Horizontal action bar with session info and controls.
class DashboardActionBar extends ConsumerWidget {
  const DashboardActionBar({
    super.key,
    required this.urlTag,
    required this.sessionId,
    required this.onSynthesisResult,
  });

  final String urlTag;
  final int sessionId;
  final void Function(String answer) onSynthesisResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scribeState = ref.watch(scribeActionsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpSpacing.lg,
        vertical: SpSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SpColors.border)),
      ),
      child: Row(
        children: [
          Text(
            '/$urlTag/[room#]',
            style: SpTypography.caption,
          ),
          const Spacer(),
          SpSecondaryButton(
            label: 'copy url',
            icon: Icons.copy,
            onPressed: () {
              final baseUrl = Uri.base.origin;
              Clipboard.setData(ClipboardData(text: '$baseUrl/$urlTag/'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('url copied')),
              );
            },
          ),
          const SizedBox(width: SpSpacing.sm),
          SpSecondaryButton(
            label: 'synthesize',
            icon: Icons.auto_awesome,
            isLoading: scribeState.isSynthesizing,
            onPressed: scribeState.isSynthesizing
                ? null
                : () async {
                    try {
                      final response = await ref
                          .read(scribeActionsProvider.notifier)
                          .synthesizeAllRooms(sessionId);
                      onSynthesisResult(response.answer);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(friendlyError(e))),
                        );
                      }
                    }
                  },
          ),
        ],
      ),
    );
  }
}
