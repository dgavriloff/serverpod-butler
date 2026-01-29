import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_button.dart';
import '../../../core/widgets/sp_card.dart';
import '../../../core/widgets/sp_text_field.dart';
import '../../../main.dart';

/// Card that lets a student join a session by tag.
class JoinSessionCard extends StatefulWidget {
  const JoinSessionCard({super.key});

  @override
  State<JoinSessionCard> createState() => _JoinSessionCardState();
}

class _JoinSessionCardState extends State<JoinSessionCard> {
  final _tagController = TextEditingController();
  bool _isJoining = false;
  String? _error;

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isEmpty) return;

    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      final liveSession = await client.session.getLiveSessionByTag(tag);
      if (!mounted) return;

      if (liveSession == null) {
        setState(() {
          _error = 'session "$tag" not found';
          _isJoining = false;
        });
        return;
      }

      context.go('/$tag');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'failed to join session';
        _isJoining = false;
      });
    }
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
          if (_error != null) ...[
            const SizedBox(height: SpSpacing.sm),
            Text(
              _error!,
              style: SpTypography.caption.copyWith(color: SpColors.live),
            ),
          ],
          const SizedBox(height: SpSpacing.md),
          SpPrimaryButton(
            label: 'join',
            onPressed: _isJoining ? null : _submit,
            isLoading: _isJoining,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
