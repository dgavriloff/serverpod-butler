import 'package:flutter/material.dart';
import '../theme/sp_colors.dart';
import '../theme/sp_durations.dart';
import '../theme/sp_radius.dart';
import '../theme/sp_spacing.dart';
import '../theme/sp_typography.dart';

/// 8px colored circle for status indication.
class SpStatusDot extends StatelessWidget {
  const SpStatusDot({
    super.key,
    required this.color,
    this.size = 8,
    this.semanticLabel,
  });

  const SpStatusDot.live({super.key, this.size = 8, this.semanticLabel = 'live'})
      : color = SpColors.live;

  const SpStatusDot.online({super.key, this.size = 8, this.semanticLabel = 'online'})
      : color = SpColors.success;

  final Color color;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Pill-shaped "live" badge with pulsing red dot.
class SpLiveBadge extends StatefulWidget {
  const SpLiveBadge({super.key});

  @override
  State<SpLiveBadge> createState() => _SpLiveBadgeState();
}

class _SpLiveBadgeState extends State<SpLiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SpDurations.pulse,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Recording live',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpSpacing.sm,
          vertical: SpSpacing.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: SpRadius.pillBorder,
          border: Border.all(color: SpColors.live.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: const SpStatusDot.live(size: 6),
            ),
            const SizedBox(width: SpSpacing.xs),
            Text(
              'live',
              style: SpTypography.caption.copyWith(
                color: SpColors.live,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
