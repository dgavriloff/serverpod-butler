import 'package:flutter/material.dart';
import '../theme/sp_colors.dart';
import '../theme/sp_radius.dart';
import '../theme/sp_spacing.dart';

/// Shimmer-style loading placeholder.
///
/// Left-to-right sweep animation. Used in place of spinners everywhere.
class SpSkeleton extends StatefulWidget {
  const SpSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<SpSkeleton> createState() => _SpSkeletonState();
}

class _SpSkeletonState extends State<SpSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-0.5 + 2.0 * _controller.value, 0),
              colors: const [
                SpColors.surfaceTertiary,
                SpColors.border,
                SpColors.surfaceTertiary,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Card-shaped skeleton placeholder.
class SpCardSkeleton extends StatelessWidget {
  const SpCardSkeleton({
    super.key,
    this.height = 120,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: SpColors.background,
        borderRadius: SpRadius.cardBorder,
        border: Border.all(color: SpColors.border),
      ),
      padding: SpSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpSkeleton(width: 100, height: 16),
          const SizedBox(height: SpSpacing.sm),
          const SpSkeleton(height: 12),
          const SizedBox(height: SpSpacing.xs),
          SpSkeleton(width: MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.first,
          ).size.width * 0.6, height: 12),
        ],
      ),
    );
  }
}

/// Text-line skeleton placeholder with configurable width.
class SpTextSkeleton extends StatelessWidget {
  const SpTextSkeleton({
    super.key,
    this.width,
    this.height = 12,
  });

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SpSkeleton(width: width, height: height);
  }
}

/// Animated builder that works with AnimationController.
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  final Widget Function(BuildContext context, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
