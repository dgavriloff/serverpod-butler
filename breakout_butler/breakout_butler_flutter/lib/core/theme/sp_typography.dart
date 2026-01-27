import 'package:flutter/painting.dart';
import 'sp_colors.dart';

/// scratchpad design system — type scale.
///
/// System fonts only. Weight over size. Generous line-height.
/// Lowercase bias enforced at the content level, not here.
abstract final class SpTypography {
  static const display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: SpColors.textPrimary,
  );

  static const pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: SpColors.textPrimary,
  );

  static const section = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: SpColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: SpColors.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: SpColors.textTertiary,
  );

  static const overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: SpColors.textSecondary,
  );
}
