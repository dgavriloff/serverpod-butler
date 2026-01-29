import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_card.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../../core/widgets/sp_status_indicator.dart';

/// Room card showing room number, content preview, and activity status.
class RoomCard extends StatefulWidget {
  const RoomCard({
    super.key,
    required this.roomNumber,
    this.content,
    this.onTap,
    this.isSelected = false,
    this.showActivity = true,
  });

  final int roomNumber;
  final String? content;
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
            if (hasContent && widget.showActivity)
              const Positioned(
                top: 0,
                right: 0,
                child: SpStatusDot.online(),
              ),
          ],
        ),
      ),
    );
  }
}
