import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../room/providers/room_providers.dart';
import 'room_card.dart';

/// Grid of room cards for the professor dashboard.
class RoomsGrid extends ConsumerWidget {
  const RoomsGrid({
    super.key,
    required this.sessionId,
    required this.roomCount,
    this.onRoomTap,
  });

  final int sessionId;
  final int roomCount;
  final void Function(int roomNumber, String content)? onRoomTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomContents = ref.watch(roomContentsProvider(sessionId));

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,
          childAspectRatio: 1.2,
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
            onTap: onRoomTap != null
                ? () => onRoomTap!(roomNumber, content)
                : null,
          );
        },
      ),
    );
  }
}
