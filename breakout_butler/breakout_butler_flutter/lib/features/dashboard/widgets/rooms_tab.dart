import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_button.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../room/providers/room_providers.dart';
import '../../scribe/providers/scribe_providers.dart';
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
  String? _synthesisResult;

  @override
  Widget build(BuildContext context) {
    final roomContents = ref.watch(roomContentsProvider(widget.sessionId));
    final scribeState = ref.watch(scribeActionsProvider);

    // Count active rooms
    final activeCount = roomContents.values.where((c) => c.isNotEmpty).length;

    return Column(
      children: [
        // Action bar
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpSpacing.md,
            vertical: SpSpacing.sm,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: SpColors.border)),
          ),
          child: Row(
            children: [
              SpHighlight(
                child: Text('rooms', style: SpTypography.section),
              ),
              const SizedBox(width: SpSpacing.md),
              Text(
                '$activeCount of ${widget.roomCount} active',
                style: SpTypography.caption.copyWith(
                  color: SpColors.textTertiary,
                ),
              ),
              const Spacer(),
              SpSecondaryButton(
                label: 'copy url',
                icon: Icons.copy,
                onPressed: () {
                  final baseUrl = Uri.base.origin;
                  Clipboard.setData(
                      ClipboardData(text: '$baseUrl/${widget.urlTag}/'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('url copied')),
                  );
                },
              ),
              const SizedBox(width: SpSpacing.sm),
              SpSecondaryButton(
                label: 'synthesize',
                icon: Icons.auto_awesome,
                isLoading: scribeState.isSynthesizing,
                onPressed: scribeState.isSynthesizing
                    ? null
                    : () async {
                        final response = await ref
                            .read(scribeActionsProvider.notifier)
                            .synthesizeAllRooms(widget.sessionId);
                        setState(() => _synthesisResult = response.answer);
                      },
              ),
            ],
          ),
        ),

        // Synthesis result
        if (_synthesisResult != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SpSpacing.md),
            decoration: const BoxDecoration(
              color: SpColors.aiSurface,
              border: Border(bottom: BorderSide(color: SpColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 14, color: SpColors.aiAccent),
                    const SizedBox(width: SpSpacing.xs),
                    Text(
                      'synthesis',
                      style: SpTypography.overline
                          .copyWith(color: SpColors.aiAccent),
                    ),
                  ],
                ),
                const SizedBox(height: SpSpacing.sm),
                Text(_synthesisResult!, style: SpTypography.body),
              ],
            ),
          ),

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
                final content = roomContents[roomNumber] ?? '';

                return RoomCard(
                  roomNumber: roomNumber,
                  content: content,
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
