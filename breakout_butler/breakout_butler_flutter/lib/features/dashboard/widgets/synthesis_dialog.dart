import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';

/// Dialog that displays the AI synthesis result from all rooms.
class SynthesisDialog extends StatelessWidget {
  const SynthesisDialog({super.key, required this.result});

  final String result;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
        child: Padding(
          padding: const EdgeInsets.all(SpSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: SpColors.aiAccent),
                  const SizedBox(width: SpSpacing.xs),
                  Text(
                    'synthesis',
                    style: SpTypography.section.copyWith(color: SpColors.aiAccent),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: SpSpacing.md),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(result, style: SpTypography.body),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
