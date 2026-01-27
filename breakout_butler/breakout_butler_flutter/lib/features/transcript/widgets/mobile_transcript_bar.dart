import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../providers/recording_providers.dart';
import '../providers/transcript_providers.dart';

/// Compact bottom bar for mobile showing latest transcript + rec button.
class MobileTranscriptBar extends ConsumerWidget {
  const MobileTranscriptBar({
    super.key,
    required this.sessionId,
    this.onExpand,
  });

  final int sessionId;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transcriptState = ref.watch(transcriptStateProvider(sessionId));
    final recordingState = ref.watch(recordingControllerProvider(sessionId));

    final displayText = transcriptState.interimText.isNotEmpty
        ? transcriptState.interimText
        : (transcriptState.chunks.isNotEmpty
            ? transcriptState.chunks.last
            : 'no transcript');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpSpacing.sm,
        vertical: SpSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: SpColors.background,
        border: Border(top: BorderSide(color: SpColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onExpand,
                child: Text(
                  displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SpTypography.caption.copyWith(
                    fontStyle: transcriptState.interimText.isNotEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SpSpacing.sm),
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: () => ref
                    .read(recordingControllerProvider(sessionId).notifier)
                    .toggle(),
                icon: Icon(
                  recordingState.isRecording ? Icons.stop : Icons.mic,
                  size: 14,
                ),
                label: Text(recordingState.isRecording ? 'stop' : 'rec'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: recordingState.isRecording
                      ? SpColors.live
                      : SpColors.primaryAction,
                  foregroundColor: SpColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
