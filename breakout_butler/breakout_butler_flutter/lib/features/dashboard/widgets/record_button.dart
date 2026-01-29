import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../transcript/providers/recording_providers.dart';

/// Compact record button for the nav bar.
///
/// Shows mic icon when not recording, blinking red dot when recording.
class RecordButton extends ConsumerWidget {
  const RecordButton({super.key, required this.sessionId, this.compact = false});

  final int sessionId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingControllerProvider(sessionId));

    // When recording, show blinking red dot button
    if (state.isRecording) {
      return OutlinedButton(
        onPressed: () =>
            ref.read(recordingControllerProvider(sessionId).notifier).toggle(),
        style: OutlinedButton.styleFrom(
          foregroundColor: SpColors.live,
          side: const BorderSide(color: SpColors.live),
        ),
        child: compact
            ? const _BlinkingDot()
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BlinkingDot(),
                  SizedBox(width: 8),
                  Text('stop'),
                ],
              ),
      );
    }

    // When not recording, show mic icon
    return OutlinedButton(
      onPressed: () =>
          ref.read(recordingControllerProvider(sessionId).notifier).toggle(),
      style: OutlinedButton.styleFrom(
        foregroundColor: SpColors.textSecondary,
        side: const BorderSide(color: SpColors.border),
      ),
      child: compact
          ? Icon(Icons.mic_none, size: 18, color: SpColors.textSecondary)
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic_none, size: 16),
                SizedBox(width: 8),
                Text('rec'),
              ],
            ),
    );
  }
}

/// Blinking red dot indicator for recording state.
class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: SpColors.live,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
