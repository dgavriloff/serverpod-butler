import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';

/// Dashboard tabs: content vs rooms.
enum DashboardTab { content, rooms }

/// Tab selector for the professor dashboard.
class DashboardTabBar extends StatelessWidget {
  const DashboardTabBar({
    super.key,
    required this.currentTab,
    required this.onChanged,
  });

  final DashboardTab currentTab;
  final ValueChanged<DashboardTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpSpacing.lg,
        vertical: SpSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SpColors.border)),
      ),
      child: Row(
        children: [
          _TabLabel(
            label: 'content',
            isSelected: currentTab == DashboardTab.content,
            onTap: () => onChanged(DashboardTab.content),
          ),
          const SizedBox(width: SpSpacing.lg),
          _TabLabel(
            label: 'rooms',
            isSelected: currentTab == DashboardTab.rooms,
            onTap: () => onChanged(DashboardTab.rooms),
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
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
            // Yellow highlight underline
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
              style: SpTypography.section.copyWith(
                color: isSelected ? SpColors.textPrimary : SpColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
