import 'package:flutter/material.dart';
import 'sp_colors.dart';
import 'sp_radius.dart';
import 'sp_typography.dart';

/// Builds the breakoutpad light theme from design tokens.
///
/// Light only for now. Dark theme support planned for later.
ThemeData buildBreakoutpadTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: SpColors.background,
    colorScheme: const ColorScheme.light(
      surface: SpColors.background,
      primary: SpColors.primaryAction,
      onPrimary: SpColors.background,
      secondary: SpColors.surfaceSecondary,
      onSecondary: SpColors.textPrimary,
      error: SpColors.live,
      onError: SpColors.background,
      onSurface: SpColors.textPrimary,
      outline: SpColors.border,
    ),

    // ── Cards ───────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      elevation: 0,
      color: SpColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: SpRadius.cardBorder,
        side: const BorderSide(color: SpColors.border),
      ),
      margin: EdgeInsets.zero,
    ),

    // ── Buttons ─────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SpColors.primaryAction,
        foregroundColor: SpColors.background,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: SpRadius.buttonBorder),
        textStyle: SpTypography.body.copyWith(
          fontWeight: FontWeight.w600,
          color: SpColors.background,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SpColors.textPrimary,
        side: const BorderSide(color: SpColors.borderInput),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: SpRadius.buttonBorder),
        textStyle: SpTypography.body.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SpColors.primaryAction,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: SpTypography.body.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Inputs ──────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: SpRadius.inputBorder,
        borderSide: const BorderSide(color: SpColors.borderInput),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: SpRadius.inputBorder,
        borderSide: const BorderSide(color: SpColors.borderInput),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: SpRadius.inputBorder,
        borderSide: const BorderSide(color: SpColors.primaryAction, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: SpRadius.inputBorder,
        borderSide: const BorderSide(color: SpColors.live),
      ),
      hintStyle: SpTypography.body.copyWith(color: SpColors.textPlaceholder),
      labelStyle: SpTypography.caption.copyWith(color: SpColors.textSecondary),
    ),

    // ── AppBar ──────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: SpColors.background,
      foregroundColor: SpColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    // ── Dividers ────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: SpColors.border,
      thickness: 1,
      space: 1,
    ),

    // ── Dialog ──────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: SpColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: SpRadius.cardBorder,
        side: const BorderSide(color: SpColors.border),
      ),
    ),

    // ── Snackbar ────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SpColors.textPrimary,
      contentTextStyle: SpTypography.body.copyWith(color: SpColors.background),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: SpRadius.buttonBorder),
      elevation: 0,
    ),

    // ── Bottom Sheet ────────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: SpColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
  );
}
