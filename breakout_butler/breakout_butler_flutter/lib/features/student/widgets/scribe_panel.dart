import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import 'scribe_input.dart';
import 'lecture_context.dart';

/// Right sidebar panel for the student room.
///
/// Shows sparkle icon + "scribe" header, lecture transcript context,
/// and the ask scribe input.
class ScribePanel extends StatelessWidget {
  const ScribePanel({super.key, required this.sessionId});

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
              Text('scribe', style: SpTypography.section),
            ],
          ),
        ),

        // Lecture context (scrollable transcript)
        Expanded(
          child: LectureContext(sessionId: sessionId),
        ),

        // Divider
        const Divider(height: 1),

        // Ask scribe input
        Padding(
          padding: const EdgeInsets.symmetric(vertical: SpSpacing.sm),
          child: ScribeInput(sessionId: sessionId),
        ),
      ],
    );
  }
}
