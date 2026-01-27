import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_card.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../../core/widgets/sp_status_indicator.dart';

/// Individual room card showing room number, content preview, and activity.
class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.roomNumber,
    required this.content,
    this.onTap,
  });

  final int roomNumber;
  final String content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasContent = content.isNotEmpty;

    return SpCard(
      hoverable: true,
      onTap: onTap,
      padding: const EdgeInsets.all(SpSpacing.md),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SpHighlight(
                child: Text(
                  '$roomNumber',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    color: SpColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: SpSpacing.xs),
              Text('room $roomNumber', style: SpTypography.overline),
              const SizedBox(height: SpSpacing.sm),
              Expanded(
                child: Text(
                  hasContent ? content : 'no activity yet',
                  style: SpTypography.caption.copyWith(
                    color: hasContent
                        ? SpColors.textTertiary
                        : SpColors.textPlaceholder,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (hasContent)
            const Positioned(
              top: 0,
              right: 0,
              child: SpStatusDot.online(),
            ),
        ],
      ),
    );
  }
}
