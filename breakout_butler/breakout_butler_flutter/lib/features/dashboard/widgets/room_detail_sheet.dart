import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_ai_card.dart';
import '../../../core/widgets/sp_button.dart';
import '../../../core/widgets/sp_skeleton.dart';
import '../../butler/providers/butler_providers.dart';

/// Shows full room content + butler AI summary.
class RoomDetailSheet extends ConsumerStatefulWidget {
  const RoomDetailSheet({
    super.key,
    required this.sessionId,
    required this.roomNumber,
    required this.content,
  });

  final int sessionId;
  final int roomNumber;
  final String content;

  @override
  ConsumerState<RoomDetailSheet> createState() => _RoomDetailSheetState();
}

class _RoomDetailSheetState extends ConsumerState<RoomDetailSheet> {
  String? _summary;
  bool _isSummarizing = false;

  Future<void> _summarize() async {
    setState(() => _isSummarizing = true);
    try {
      final response = await ref
          .read(butlerActionsProvider.notifier)
          .summarizeRoom(widget.sessionId, widget.roomNumber);
      if (mounted) {
        setState(() {
          _summary = response.answer;
          _isSummarizing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSummarizing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('room ${widget.roomNumber}', style: SpTypography.pageTitle),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.content.isEmpty ? 'no content yet.' : widget.content,
                style: SpTypography.body,
              ),
              const SizedBox(height: SpSpacing.lg),
              if (_summary != null)
                SpAiCard(
                  header: 'butler summary',
                  child: Text(_summary!, style: SpTypography.body),
                )
              else if (_isSummarizing)
                const SpAiCard(
                  header: 'summarizing...',
                  child: SpSkeleton(height: 48),
                )
              else
                SpSecondaryButton(
                  label: 'ask butler to summarize',
                  icon: Icons.auto_awesome,
                  onPressed: widget.content.isNotEmpty ? _summarize : null,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('close'),
        ),
      ],
    );
  }
}
