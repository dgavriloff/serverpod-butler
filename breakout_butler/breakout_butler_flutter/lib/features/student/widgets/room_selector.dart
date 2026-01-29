import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_button.dart';
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
  int? _selectedRoom;

  void _joinRoom() {
    if (_selectedRoom != null) {
      context.go('/${widget.urlTag}/$_selectedRoom');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(SpSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text('join a room', style: SpTypography.pageTitle),
              const SizedBox(height: SpSpacing.xs),
              Text(
                'select your breakout room to begin',
                style: SpTypography.caption.copyWith(
                  color: SpColors.textTertiary,
                ),
              ),
              const SizedBox(height: SpSpacing.xl),

              // Room grid using existing RoomCard
              Wrap(
                spacing: SpSpacing.md,
                runSpacing: SpSpacing.md,
                alignment: WrapAlignment.center,
                children: List.generate(widget.roomCount, (index) {
                  final roomNumber = index + 1;
                  final isSelected = _selectedRoom == roomNumber;

                  return SizedBox(
                    width: 120,
                    height: 100,
                    child: RoomCard(
                      roomNumber: roomNumber,
                      isSelected: isSelected,
                      showActivity: false,
                      onTap: () => setState(() => _selectedRoom = roomNumber),
                    ),
                  );
                }),
              ),

              const SizedBox(height: SpSpacing.xl),

              // Join button
              SpPrimaryButton(
                label: _selectedRoom != null
                    ? 'join room $_selectedRoom'
                    : 'select a room',
                onPressed: _selectedRoom != null ? _joinRoom : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
