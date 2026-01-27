import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_button.dart';
import '../../../core/widgets/sp_card.dart';
import '../../../core/widgets/sp_text_field.dart';

/// Card that lets a student join an existing room by name + group number.
class JoinSessionCard extends StatefulWidget {
  const JoinSessionCard({super.key});

  @override
  State<JoinSessionCard> createState() => _JoinSessionCardState();
}

class _JoinSessionCardState extends State<JoinSessionCard> {
  final _roomController = TextEditingController();
  final _groupController = TextEditingController();

  @override
  void dispose() {
    _roomController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _submit() {
    final roomName = _roomController.text.trim().toLowerCase();
    final groupNumber = _groupController.text.trim();
    if (roomName.isEmpty || groupNumber.isEmpty) return;
    context.go('/$roomName/$groupNumber');
  }

  @override
  Widget build(BuildContext context) {
    return SpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('join a room', style: SpTypography.section),
          const SizedBox(height: SpSpacing.md),
          SpTextField(
            controller: _roomController,
            label: 'room name',
            hint: 'e.g., psych101',
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-_]')),
            ],
          ),
          const SizedBox(height: SpSpacing.sm),
          SpTextField(
            controller: _groupController,
            label: 'group number',
            hint: 'e.g., 1',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
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
