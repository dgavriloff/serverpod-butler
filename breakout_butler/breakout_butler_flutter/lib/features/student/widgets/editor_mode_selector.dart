import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';

/// Write vs draw mode for the collaborative editor.
enum EditorMode { write, draw }

/// Bottom-right toggle: "write  draw" with yellow highlight on the active option.
class EditorModeSelector extends StatelessWidget {
  const EditorModeSelector({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  final EditorMode currentMode;
  final ValueChanged<EditorMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeLabel(
          label: 'write',
          isSelected: currentMode == EditorMode.write,
          onTap: () => onChanged(EditorMode.write),
        ),
        const SizedBox(width: SpSpacing.md),
        _ModeLabel(
          label: 'draw',
          isSelected: currentMode == EditorMode.draw,
          onTap: () => onChanged(EditorMode.draw),
        ),
      ],
    );
  }
}

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpSpacing.xs,
          vertical: SpSpacing.xs,
        ),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // Yellow highlight underline (like breadcrumbs)
            if (isSelected)
              Positioned(
                left: 0,
                right: 0,
                bottom: 1,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: SpColors.highlight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            Text(
              label,
              style: SpTypography.body.copyWith(
                color:
                    isSelected ? SpColors.textPrimary : SpColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
