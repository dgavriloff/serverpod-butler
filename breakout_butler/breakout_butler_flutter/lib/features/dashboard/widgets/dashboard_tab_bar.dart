import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/layout/sp_breakpoints.dart';
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
    required this.urlTag,
  });

  final DashboardTab currentTab;
  final ValueChanged<DashboardTab> onChanged;
  final String urlTag;

  void _copyLink(BuildContext context) {
    final uri = Uri.base;
    final link = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}/app#/$urlTag';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = screenSizeOf(context) == SpScreenSize.mobile;

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
          const Spacer(),
          OutlinedButton(
            onPressed: () => _copyLink(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: SpColors.textSecondary,
              side: const BorderSide(color: SpColors.border),
            ),
            child: isMobile
                ? Icon(Icons.link, size: 18, color: SpColors.textSecondary)
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link, size: 16),
                      SizedBox(width: 8),
                      Text('copy link'),
                    ],
                  ),
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
