import 'package:flutter/material.dart';
import '../theme/sp_colors.dart';
import '../theme/sp_radius.dart';
import '../theme/sp_spacing.dart';
import '../theme/sp_typography.dart';

/// AI-styled card — cream background, left-border accent, sparkle header.
///
/// Used for scribe responses, AI insights, and generated content.
/// "intelligence at the periphery" — subtle, not center-stage.
class SpAiCard extends StatelessWidget {
  const SpAiCard({
    super.key,
    this.header,
    required this.child,
  });

  final String? header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SpColors.aiSurface,
        borderRadius: SpRadius.cardBorder,
        border: const Border(
          left: BorderSide(color: SpColors.aiAccent, width: 3),
          top: BorderSide(color: SpColors.border),
          right: BorderSide(color: SpColors.border),
          bottom: BorderSide(color: SpColors.border),
        ),
      ),
      padding: SpSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: SpColors.aiAccent,
                ),
                const SizedBox(width: SpSpacing.xs),
                Text(
                  header!,
                  style: SpTypography.overline.copyWith(
                    color: SpColors.aiAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpSpacing.sm),
          ],
          child,
        ],
      ),
    );
  }
}
