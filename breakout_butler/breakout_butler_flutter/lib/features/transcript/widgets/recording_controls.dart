import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../providers/recording_providers.dart';

/// Record/stop button with status text.
class RecordingControls extends ConsumerWidget {
  const RecordingControls({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingControllerProvider(sessionId));

    return Padding(
      padding: const EdgeInsets.all(SpSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  ref.read(recordingControllerProvider(sessionId).notifier).toggle(),
              icon: Icon(
                state.isRecording ? Icons.stop : Icons.fiber_manual_record,
                size: 14,
              ),
              label: Text(state.isRecording ? 'stop' : 'rec'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    state.isRecording ? SpColors.live : SpColors.primaryAction,
                foregroundColor: SpColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (state.isRecording) ...[
            const SizedBox(height: SpSpacing.xs),
            Text(
              state.usingSpeechApi ? 'listening...' : 'transcribing (server)...',
              style: SpTypography.overline.copyWith(color: SpColors.live),
            ),
          ],
          if (state.error != null) ...[
            const SizedBox(height: SpSpacing.xs),
            Text(
              state.error!,
              style: SpTypography.caption.copyWith(color: SpColors.live),
            ),
          ],
        ],
      ),
    );
  }
}
