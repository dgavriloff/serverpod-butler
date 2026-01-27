import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import 'butler_input.dart';
import 'lecture_context.dart';

/// Right sidebar panel for the student room.
///
/// Shows sparkle icon + "butler" header, lecture transcript context,
/// and the ask butler input.
class ButlerPanel extends StatelessWidget {
  const ButlerPanel({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(SpSpacing.md),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: SpColors.border)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: SpColors.aiAccent,
              ),
              const SizedBox(width: SpSpacing.sm),
              Text('butler', style: SpTypography.section),
            ],
          ),
        ),

        // Lecture context (scrollable transcript)
        Expanded(
          child: LectureContext(sessionId: sessionId),
        ),

        // Divider
        const Divider(height: 1),

        // Ask butler input
        Padding(
          padding: const EdgeInsets.symmetric(vertical: SpSpacing.sm),
          child: ButlerInput(sessionId: sessionId),
        ),
      ],
    );
  }
}
