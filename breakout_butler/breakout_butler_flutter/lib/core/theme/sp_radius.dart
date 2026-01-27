import 'package:flutter/painting.dart';

/// breakoutpad design system — border radius tokens.
abstract final class SpRadius {
  static const double card = 8;
  static const double button = 6;
  static const double input = 6;
  static const double pill = 12;

  // ── BorderRadius presets ────────────────────────────────────────────
  static final cardBorder = BorderRadius.circular(card);
  static final buttonBorder = BorderRadius.circular(button);
  static final inputBorder = BorderRadius.circular(input);
  static final pillBorder = BorderRadius.circular(pill);
}
