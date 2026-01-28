import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';

/// Horizontal divider with "or" centered on it.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: SpColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpSpacing.md),
          child: Text(
            'or',
            style: SpTypography.caption.copyWith(color: SpColors.textTertiary),
          ),
        ),
        const Expanded(child: Divider(color: SpColors.border)),
      ],
    );
  }
}
