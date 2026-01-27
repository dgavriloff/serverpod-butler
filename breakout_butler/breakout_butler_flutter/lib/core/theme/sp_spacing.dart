import 'package:flutter/painting.dart';

/// scratchpad design system — spacing tokens.
///
/// 4px base unit. Aggressive whitespace.
abstract final class SpSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // ── Common EdgeInsets ───────────────────────────────────────────────
  static const cardPadding = EdgeInsets.all(20);
  static const pagePadding = EdgeInsets.all(48);
  static const pagePaddingMobile = EdgeInsets.all(16);
  static const sectionGap = SizedBoxHeight(lg);
  static const itemGap = SizedBoxHeight(sm);
}

/// Convenience: const-constructible vertical spacer.
class SizedBoxHeight {
  const SizedBoxHeight(this.height);
  final double height;
}
