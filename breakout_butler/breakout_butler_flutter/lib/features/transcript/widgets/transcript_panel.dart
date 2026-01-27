import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../../core/widgets/sp_status_indicator.dart';
import '../../../core/widgets/sp_text_field.dart';
import '../../../widgets/audio_visualizer.dart';
import '../providers/recording_providers.dart';
import '../providers/transcript_providers.dart';
import 'recording_controls.dart';
import 'transcript_list.dart';

/// Right sidebar panel for transcript + recording controls.
class TranscriptPanel extends ConsumerStatefulWidget {
  const TranscriptPanel({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<TranscriptPanel> createState() => _TranscriptPanelState();
}

class _TranscriptPanelState extends ConsumerState<TranscriptPanel> {
  final _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final recordingState =
        ref.watch(recordingControllerProvider(widget.sessionId));
    final recordingNotifier =
        ref.read(recordingControllerProvider(widget.sessionId).notifier);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpSpacing.md,
            vertical: SpSpacing.sm,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: SpColors.border)),
          ),
          child: Row(
            children: [
              if (recordingState.isRecording) ...[
                const SpLiveBadge(),
                const SizedBox(width: SpSpacing.sm),
              ],
              SpHighlight(child: Text('transcript', style: SpTypography.section)),
              const Spacer(),
              if (recordingState.isRecording &&
                  recordingNotifier.audioLevelStream != null)
                AudioVisualizer(
                  audioLevelStream: recordingNotifier.audioLevelStream!,
                  width: 60,
                  height: 18,
                  color: SpColors.live,
                ),
            ],
          ),
        ),

        // Recording controls
        RecordingControls(sessionId: widget.sessionId),

        const Divider(height: 1),

        // Transcript list
        Expanded(child: TranscriptList(sessionId: widget.sessionId)),

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
                  hint: 'add text...',
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
    );
  }
}
