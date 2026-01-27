import 'dart:async';
import 'package:flutter/material.dart';

/// Compact animated bar visualizer driven by a stream of audio levels.
class AudioVisualizer extends StatefulWidget {
  final Stream<List<double>> audioLevelStream;
  final double width;
  final double height;
  final Color color;

  const AudioVisualizer({
    super.key,
    required this.audioLevelStream,
    this.width = 120,
    this.height = 28,
    this.color = Colors.red,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> {
  List<double> _levels = List.filled(10, 0.0);
  StreamSubscription<List<double>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.audioLevelStream.listen((levels) {
      if (mounted) {
        setState(() {
          _levels = levels;
        });
      }
    });
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioLevelStream != widget.audioLevelStream) {
      _subscription?.cancel();
      _subscription = widget.audioLevelStream.listen((levels) {
        if (mounted) {
          setState(() {
            _levels = levels;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barCount = _levels.length;
    final barWidth = (widget.width - (barCount - 1) * 2) / barCount;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(barCount, (i) {
          // Minimum bar height so the visualizer is visible even when silent
          final level = _levels[i].clamp(0.0, 1.0);
          final minHeight = widget.height * 0.12;
          final barHeight = minHeight + (widget.height - minHeight) * level;

          return Padding(
            padding: EdgeInsets.only(right: i < barCount - 1 ? 2 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOut,
              width: barWidth,
              height: barHeight,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.6 + 0.4 * level),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
