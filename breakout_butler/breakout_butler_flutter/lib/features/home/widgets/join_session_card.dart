import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_button.dart';
import '../../../core/widgets/sp_card.dart';
import '../../../core/widgets/sp_text_field.dart';

/// Card that lets a student join a session by tag.
class JoinSessionCard extends StatefulWidget {
  const JoinSessionCard({super.key});

  @override
  State<JoinSessionCard> createState() => _JoinSessionCardState();
}

class _JoinSessionCardState extends State<JoinSessionCard> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _submit() {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isEmpty) return;
    context.go('/$tag');
  }

  @override
  Widget build(BuildContext context) {
    return SpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('join a session', style: SpTypography.section),
          const SizedBox(height: SpSpacing.md),
          SpTextField(
            controller: _tagController,
            label: 'session tag',
            hint: 'e.g., psych101',
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-_]')),
            ],
          ),
          const SizedBox(height: SpSpacing.md),
          SpPrimaryButton(
            label: 'join',
            onPressed: _submit,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
