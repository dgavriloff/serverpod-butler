import 'package:flutter/material.dart';
import '../theme/sp_colors.dart';
import '../theme/sp_radius.dart';
import '../theme/sp_typography.dart';

/// scratchpad primary button — blue bg, white text, 6px radius.
///
/// When [isLoading] is true, shows a subtle shimmer placeholder
/// instead of a spinner (design doc: never spinners).
class SpPrimaryButton extends StatelessWidget {
  const SpPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 80,
            height: 14,
            child: Container(
              decoration: BoxDecoration(
                color: SpColors.background.withValues(alpha: 0.3),
                borderRadius: SpRadius.buttonBorder,
              ),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

/// scratchpad secondary button — transparent bg, border, dark text.
class SpSecondaryButton extends StatelessWidget {
  const SpSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 80,
            height: 14,
            child: Container(
              decoration: BoxDecoration(
                color: SpColors.textPlaceholder.withValues(alpha: 0.3),
                borderRadius: SpRadius.buttonBorder,
              ),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

/// Minimal icon-only button for toolbars.
class SpIconButton extends StatelessWidget {
  const SpIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 20,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon, size: size, color: color ?? SpColors.textSecondary),
      onPressed: onPressed,
      splashRadius: 20,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
