import 'package:flutter/material.dart';
import '../theme/sp_colors.dart';
import '../theme/sp_spacing.dart';
import '../theme/sp_typography.dart';
import 'sp_highlight.dart';

/// Breadcrumb-style navigation bar.
///
/// Segments separated by " / ". Active segment in primary text,
/// inactive segments in secondary and tappable.
class SpBreadcrumbNav extends StatelessWidget {
  const SpBreadcrumbNav({
    super.key,
    required this.segments,
    this.onSegmentTap,
    this.trailing,
  });

  final List<String> segments;

  /// Called when a non-active (non-last) segment is tapped.
  /// Index corresponds to position in [segments].
  final void Function(int index)? onSegmentTap;

  /// Optional trailing widget (e.g., action buttons).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: SpSpacing.lg),
      decoration: const BoxDecoration(
        color: SpColors.background,
        border: Border(
          bottom: BorderSide(color: SpColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < segments.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpSpacing.sm,
                      ),
                      child: Text(
                        '/',
                        style: SpTypography.body.copyWith(
                          color: SpColors.textTertiary,
                        ),
                      ),
                    ),
                  _buildSegment(i),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  Widget _buildSegment(int index) {
    final isActive = index == segments.length - 1;
    final style = SpTypography.body.copyWith(
      color: isActive ? SpColors.textPrimary : SpColors.textSecondary,
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
    );

    final textWidget = Text(segments[index], style: style);
    final child = isActive
        ? SpHighlight(child: textWidget)
        : textWidget;

    if (isActive || onSegmentTap == null) {
      return child;
    }

    return GestureDetector(
      onTap: () => onSegmentTap!(index),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: child,
      ),
    );
  }
}
