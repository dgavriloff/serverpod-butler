import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_spacing.dart';
import '../../room/providers/room_providers.dart';
import 'room_card.dart';
import 'room_detail_sheet.dart';

/// Rooms tab: activity monitor grid with actions.
class RoomsTab extends ConsumerStatefulWidget {
  const RoomsTab({
    super.key,
    required this.sessionId,
    required this.roomCount,
    required this.urlTag,
  });

  final int sessionId;
  final int roomCount;
  final String urlTag;

  @override
  ConsumerState<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends ConsumerState<RoomsTab> {
  @override
  Widget build(BuildContext context) {
    final roomStates = ref.watch(roomContentsProvider(widget.sessionId));

    return Column(
      children: [
        // Rooms grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: widget.roomCount,
              itemBuilder: (context, index) {
                final roomNumber = index + 1;
                final roomState = roomStates[roomNumber];
                final content = roomState?.content ?? '';
                final occupantCount = roomState?.occupantCount ?? 0;

                return RoomCard(
                  roomNumber: roomNumber,
                  content: content,
                  occupantCount: occupantCount,
                  onTap: () => _showRoomDetail(roomNumber, content),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showRoomDetail(int roomNumber, String content) {
    showDialog(
      context: context,
      builder: (_) => RoomDetailSheet(
        sessionId: widget.sessionId,
        roomNumber: roomNumber,
        content: content,
      ),
    );
  }
}
