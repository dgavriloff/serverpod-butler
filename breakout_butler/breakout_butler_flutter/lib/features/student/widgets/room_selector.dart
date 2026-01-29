import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../dashboard/widgets/room_card.dart';

/// Room selector for students to pick which breakout room to join.
class RoomSelector extends StatefulWidget {
  const RoomSelector({
    super.key,
    required this.urlTag,
    required this.roomCount,
  });

  final String urlTag;
  final int roomCount;

  @override
  State<RoomSelector> createState() => _RoomSelectorState();
}

class _RoomSelectorState extends State<RoomSelector> {
  void _joinRoom(int roomNumber) {
    context.go('/${widget.urlTag}/$roomNumber');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text('join a room', style: SpTypography.pageTitle),
            const SizedBox(height: SpSpacing.xs),
            Text(
              'select your breakout room',
              style: SpTypography.caption.copyWith(
                color: SpColors.textTertiary,
              ),
            ),
            const SizedBox(height: SpSpacing.xl),

            // Room cards inline - tap to join directly
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.roomCount, (index) {
                final roomNumber = index + 1;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < widget.roomCount - 1 ? SpSpacing.md : 0,
                  ),
                  child: SizedBox(
                    width: 140,
                    height: 120,
                    child: RoomCard(
                      roomNumber: roomNumber,
                      showActivity: false,
                      onTap: () => _joinRoom(roomNumber),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
