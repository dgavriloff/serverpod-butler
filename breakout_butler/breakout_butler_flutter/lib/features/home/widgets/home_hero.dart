import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';

/// Hero section for the home screen — title + subtitle + feature bullets.
///
/// [alignment] controls cross-axis: centered on mobile, left-aligned on desktop.
class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    this.alignment = CrossAxisAlignment.center,
  });

  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final textAlign =
        alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.left;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text(
          'breakoutpad',
          style: SpTypography.display,
          textAlign: textAlign,
        ),
        const SizedBox(height: SpSpacing.sm),
        Text(
          'collaborative workspaces for your class',
          style: SpTypography.body.copyWith(color: SpColors.textSecondary),
          textAlign: textAlign,
        ),
        const SizedBox(height: SpSpacing.lg),
        _FeatureBullet(
          icon: Icons.groups_outlined,
          text: 'real-time breakout rooms',
        ),
        const SizedBox(height: SpSpacing.sm),
        _FeatureBullet(
          icon: Icons.auto_awesome_outlined,
          text: 'ai-powered butler assistant',
        ),
        const SizedBox(height: SpSpacing.sm),
        _FeatureBullet(
          icon: Icons.flash_on_outlined,
          text: 'zero setup, instant start',
        ),
      ],
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: SpColors.primaryAction),
        const SizedBox(width: SpSpacing.sm),
        Text(text, style: SpTypography.body),
      ],
    );
  }
}
