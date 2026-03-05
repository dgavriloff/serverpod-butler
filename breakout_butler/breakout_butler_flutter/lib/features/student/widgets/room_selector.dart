import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../main.dart';
import '../../../services/cookie_web.dart';
import '../../dashboard/widgets/room_card.dart';

/// Room selector for students to pick which breakout room to join.
class RoomSelector extends StatefulWidget {
  const RoomSelector({
    super.key,
    required this.urlTag,
    required this.roomCount,
    this.onTeacherAuthenticated,
  });

  final String urlTag;
  final int roomCount;
  final VoidCallback? onTeacherAuthenticated;

  @override
  State<RoomSelector> createState() => _RoomSelectorState();
}

class _RoomSelectorState extends State<RoomSelector> {
  void _joinRoom(int roomNumber) {
    context.go('/${widget.urlTag}/$roomNumber');
  }

  void _showPinDialog() {
    final pinController = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final pin = pinController.text.trim();
              if (pin.isEmpty) return;

              final token = await client.session.validateTeacherPin(
                widget.urlTag,
                pin,
              );

              if (token != null) {
                CookieService.set('creator_${widget.urlTag}', token);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                widget.onTeacherAuthenticated?.call();
              } else {
                setDialogState(() {
                  error = 'incorrect pin';
                });
              }
            }

            return AlertDialog(
              title: const Text('teacher pin', style: SpTypography.section),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pinController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'enter pin',
                      errorText: error,
                    ),
                    onSubmitted: (_) => submit(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('cancel'),
                ),
                TextButton(
                  onPressed: submit,
                  child: const Text('submit'),
                ),
              ],
            );
          },
        );
      },
    );
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

            // Room cards - wrap on smaller screens
            Wrap(
              spacing: SpSpacing.md,
              runSpacing: SpSpacing.md,
              alignment: WrapAlignment.center,
              children: List.generate(widget.roomCount, (index) {
                final roomNumber = index + 1;

                return SizedBox(
                  width: 140,
                  height: 120,
                  child: RoomCard(
                    roomNumber: roomNumber,
                    showActivity: false,
                    onTap: () => _joinRoom(roomNumber),
                  ),
                );
              }),
            ),

            // Teacher dashboard link
            const SizedBox(height: SpSpacing.xl),
            TextButton(
              onPressed: _showPinDialog,
              child: Text(
                'go to dashboard',
                style: SpTypography.caption.copyWith(
                  color: SpColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
