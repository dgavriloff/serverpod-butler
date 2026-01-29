import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_button.dart';
import '../../../core/widgets/sp_card.dart';
import '../../../core/widgets/sp_highlight.dart';

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
  bool _hovered = false;

  void _joinRoom() {
    if (_selectedRoom != null) {
      context.go('/${widget.urlTag}/$_selectedRoom');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(SpSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                'join a room',
                style: SpTypography.pageTitle,
              ),
              const SizedBox(height: SpSpacing.xs),
              Text(
                'select your breakout room to begin',
                style: SpTypography.caption.copyWith(
                  color: SpColors.textTertiary,
                ),
              ),
              const SizedBox(height: SpSpacing.xl),

              // Room grid
              Wrap(
                spacing: SpSpacing.md,
                runSpacing: SpSpacing.md,
                alignment: WrapAlignment.center,
                children: List.generate(widget.roomCount, (index) {
                  final roomNumber = index + 1;
                  final isSelected = _selectedRoom == roomNumber;

                  return _RoomButton(
                    roomNumber: roomNumber,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedRoom = roomNumber),
                  );
                }),
              ),

              const SizedBox(height: SpSpacing.xl),

              // Join button
              MouseRegion(
                onEnter: (_) => setState(() => _hovered = true),
                onExit: (_) => setState(() => _hovered = false),
                child: SpPrimaryButton(
                  label: _hovered && _selectedRoom != null
                      ? 'join room $_selectedRoom'
                      : 'join',
                  onPressed: _selectedRoom != null ? _joinRoom : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomButton extends StatefulWidget {
  const _RoomButton({
    required this.roomNumber,
    required this.isSelected,
    required this.onTap,
  });

  final int roomNumber;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_RoomButton> createState() => _RoomButtonState();
}

class _RoomButtonState extends State<_RoomButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final numberText = Text(
      '${widget.roomNumber}',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: widget.isSelected ? SpColors.textPrimary : SpColors.textSecondary,
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SpCard(
          hoverable: true,
          padding: const EdgeInsets.all(SpSpacing.lg),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (_hovered || widget.isSelected)
                    ? SpHighlight(child: numberText)
                    : numberText,
                const SizedBox(height: SpSpacing.xs),
                Text(
                  'room ${widget.roomNumber}',
                  style: SpTypography.overline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
