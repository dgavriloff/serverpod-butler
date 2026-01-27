import 'dart:ui';

/// scratchpad design system — color tokens.
///
/// White-forward palette with calm blue as the single CTA color.
/// No gradients, no pure black.
abstract final class SpColors {
  // ── Backgrounds & Surfaces ──────────────────────────────────────────
  static const background = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFFAFAFA);
  static const surfaceTertiary = Color(0xFFF5F5F5);

  // ── Borders ─────────────────────────────────────────────────────────
  static const border = Color(0xFFE8E8E8);
  static const borderInput = Color(0xFFE0E0E0);

  // ── Text ────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const textTertiary = Color(0xFF999999);
  static const textPlaceholder = Color(0xFFCCCCCC);

  // ── Accents ─────────────────────────────────────────────────────────
  static const primaryAction = Color(0xFF2196F3);
  static const primaryActionHover = Color(0xFF1E88E5);

  // ── Semantic ────────────────────────────────────────────────────────
  static const live = Color(0xFFFF4444);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);

  // ── AI ──────────────────────────────────────────────────────────────
  static const aiAccent = Color(0xFF5B9BD5);
  static const aiSurface = Color(0xFFFDF8F4);

  // ── Interactive states ──────────────────────────────────────────────
  static const cardHover = Color(0xFFF8F8F8);
  static const secondaryHover = Color(0xFFF5F5F5);
}
