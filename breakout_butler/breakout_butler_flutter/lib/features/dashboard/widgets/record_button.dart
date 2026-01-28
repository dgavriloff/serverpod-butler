import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../transcript/providers/recording_providers.dart';

/// Compact record button for the nav bar.
class RecordButton extends ConsumerWidget {
  const RecordButton({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingControllerProvider(sessionId));

    return TextButton.icon(
      onPressed: () =>
          ref.read(recordingControllerProvider(sessionId).notifier).toggle(),
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: state.isRecording ? SpColors.live : SpColors.textTertiary,
        ),
      ),
      label: Text(
        state.isRecording ? 'stop' : 'rec',
        style: SpTypography.body.copyWith(
          color: state.isRecording ? SpColors.live : SpColors.textSecondary,
          fontWeight: state.isRecording ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: SpSpacing.md,
          vertical: SpSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: state.isRecording ? SpColors.live : SpColors.border,
          ),
        ),
      ),
    );
  }
}
