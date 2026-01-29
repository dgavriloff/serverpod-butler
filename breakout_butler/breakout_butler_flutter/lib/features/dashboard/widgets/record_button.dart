import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/widgets/sp_status_indicator.dart';
import '../../transcript/providers/recording_providers.dart';

/// Compact record button for the nav bar.
///
/// Uses [SpLiveBadge] style when recording, outlined button when not.
class RecordButton extends ConsumerWidget {
  const RecordButton({super.key, required this.sessionId, this.compact = false});

  final int sessionId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingControllerProvider(sessionId));

    // When recording, show the live badge style
    if (state.isRecording) {
      return GestureDetector(
        onTap: () =>
            ref.read(recordingControllerProvider(sessionId).notifier).toggle(),
        child: const SpLiveBadge(),
      );
    }

    // When not recording, show outlined button (icon only on mobile)
    return OutlinedButton(
      onPressed: () =>
          ref.read(recordingControllerProvider(sessionId).notifier).toggle(),
      style: OutlinedButton.styleFrom(
        foregroundColor: SpColors.textSecondary,
        side: const BorderSide(color: SpColors.border),
      ),
      child: compact
          ? const Icon(Icons.fiber_manual_record, size: 12)
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fiber_manual_record, size: 12),
                SizedBox(width: 8),
                Text('rec'),
              ],
            ),
    );
  }
}
