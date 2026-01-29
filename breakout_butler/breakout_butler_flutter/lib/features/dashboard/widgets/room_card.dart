import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_card.dart';
import '../../../core/widgets/sp_highlight.dart';

/// Room card showing room number, content preview, and activity status.
class RoomCard extends StatefulWidget {
  const RoomCard({
    super.key,
    required this.roomNumber,
    this.content,
    this.occupantCount = 0,
    this.onTap,
    this.isSelected = false,
    this.showActivity = true,
  });

  final int roomNumber;
  final String? content;
  final int occupantCount;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showActivity;

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hasContent = widget.content?.isNotEmpty ?? false;
    final showHighlight = _hovered || widget.isSelected;

    final numberText = Text(
      '${widget.roomNumber}',
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: SpColors.textSecondary,
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SpCard(
        hoverable: true,
        onTap: widget.onTap,
        padding: const EdgeInsets.all(SpSpacing.md),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                showHighlight ? SpHighlight(child: numberText) : numberText,
                const SizedBox(height: SpSpacing.xs),
                Text('room ${widget.roomNumber}', style: SpTypography.overline),
                if (widget.showActivity) ...[
                  const SizedBox(height: SpSpacing.sm),
                  Expanded(
                    child: Text(
                      hasContent ? widget.content! : 'no activity yet',
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
              ],
            ),
            // Occupant count badge (top-right)
            if (widget.showActivity)
              Positioned(
                top: 0,
                right: 0,
                child: Builder(
                  builder: (context) {
                    final hasOccupants = widget.occupantCount > 0;
                    final color = hasOccupants
                        ? SpColors.success
                        : SpColors.textPlaceholder;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 12,
                            color: color,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.occupantCount}',
                            style: SpTypography.caption.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
