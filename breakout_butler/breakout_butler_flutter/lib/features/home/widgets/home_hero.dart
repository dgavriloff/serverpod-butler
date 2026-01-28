import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_card.dart';

/// Hero section for the home screen — title + subtitle + feature bullets
/// wrapped in an SpCard. Always left-aligned.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SpCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'breakoutpad',
            style: SpTypography.display,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: SpSpacing.sm),
          Text(
            'instant collaborative surfaces',
            style: SpTypography.body.copyWith(color: SpColors.textSecondary),
            textAlign: TextAlign.left,
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
      ),
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
