import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../room/providers/room_providers.dart';
import 'room_card.dart';
import 'room_detail_sheet.dart';

/// Rooms tab: simplified activity monitor grid.
class RoomsTab extends ConsumerWidget {
  const RoomsTab({
    super.key,
    required this.sessionId,
    required this.roomCount,
  });

  final int sessionId;
  final int roomCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomContents = ref.watch(roomContentsProvider(sessionId));

    // Count active rooms (rooms with content)
    final activeCount = roomContents.values.where((c) => c.isNotEmpty).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with activity summary
        Padding(
          padding: const EdgeInsets.all(SpSpacing.lg),
          child: Row(
            children: [
              SpHighlight(
                child: Text('rooms', style: SpTypography.section),
              ),
              const SizedBox(width: SpSpacing.md),
              Text(
                '$activeCount of $roomCount active',
                style: SpTypography.caption.copyWith(
                  color: SpColors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        // Rooms grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpSpacing.lg),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: roomCount,
              itemBuilder: (context, index) {
                final roomNumber = index + 1;
                final content = roomContents[roomNumber] ?? '';

                return RoomCard(
                  roomNumber: roomNumber,
                  content: content,
                  onTap: () => _showRoomDetail(context, roomNumber, content),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showRoomDetail(BuildContext context, int roomNumber, String content) {
    showDialog(
      context: context,
      builder: (_) => RoomDetailSheet(
        sessionId: sessionId,
        roomNumber: roomNumber,
        content: content,
      ),
    );
  }
}
