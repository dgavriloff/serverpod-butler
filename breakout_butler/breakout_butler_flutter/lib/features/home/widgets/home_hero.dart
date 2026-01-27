import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';

/// Hero section for the home screen — title + subtitle, centered.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'breakoutpad',
            style: SpTypography.display,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpSpacing.sm),
          Text(
            'collaborative workspaces for your class',
            style: SpTypography.body.copyWith(color: SpColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
