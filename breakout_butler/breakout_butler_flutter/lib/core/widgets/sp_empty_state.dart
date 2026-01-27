import 'package:flutter/material.dart';
import '../theme/sp_colors.dart';
import '../theme/sp_spacing.dart';
import '../theme/sp_typography.dart';

/// Friendly empty state — centered icon + message + optional action.
class SpEmptyState extends StatelessWidget {
  const SpEmptyState({
    super.key,
    this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData? icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 40, color: SpColors.textPlaceholder),
              const SizedBox(height: SpSpacing.md),
            ],
            Text(
              message,
              style: SpTypography.body.copyWith(color: SpColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SpSpacing.md),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
