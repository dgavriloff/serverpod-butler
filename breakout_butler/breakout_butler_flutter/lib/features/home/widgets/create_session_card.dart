import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_client/serverpod_client.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/widgets/sp_button.dart';
import '../../../core/widgets/sp_card.dart';
import '../../../core/widgets/sp_text_field.dart';
import '../../../main.dart';
import '../../../services/cookie_web.dart';

/// Card that lets a professor create a new session.
class CreateSessionCard extends StatefulWidget {
  const CreateSessionCard({super.key});

  @override
  State<CreateSessionCard> createState() => _CreateSessionCardState();
}

class _CreateSessionCardState extends State<CreateSessionCard> {
  final _tagController = TextEditingController();
  final _roomCountController = TextEditingController(text: '4');
  bool _isCreating = false;
  String? _error;

  @override
  void dispose() {
    _tagController.dispose();
    _roomCountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tag = _tagController.text.trim().toLowerCase();
    final roomCountText = _roomCountController.text.trim();

    if (tag.length < 3 || tag.length > 30) {
      setState(() => _error = 'session tag must be 3-30 characters');
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(tag)) {
      setState(() => _error = 'session tag must be alphanumeric');
      return;
    }

    final roomCount = int.tryParse(roomCountText);
    if (roomCount == null || roomCount < 1 || roomCount > 50) {
      setState(() => _error = 'room count must be between 1 and 50');
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      final session = await client.session.createSession(tag, roomCount);

      final liveSession = await client.session.startLiveSession(
        session.id!,
        tag,
      );

      if (!mounted) return;

      final token = liveSession.creatorToken ?? '';
      CookieService.set('creator_$tag', token);
      context.go('/$tag');
    } catch (e) {
      if (!mounted) return;
      String message;
      if (e is ServerpodClientInternalServerError) {
        message = 'session tag "$tag" is already in use';
      } else {
        message = friendlyError(e);
      }
      setState(() {
        _error = message;
        _isCreating = false;
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
          Text('create a session', style: SpTypography.section),
          const SizedBox(height: SpSpacing.md),
          SpTextField(
            controller: _tagController,
            label: 'session tag',
            hint: 'e.g., psych101',
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-_]')),
              LengthLimitingTextInputFormatter(30),
            ],
          ),
          const SizedBox(height: SpSpacing.sm),
          SpTextField(
            controller: _roomCountController,
            label: 'number of rooms',
            hint: '4',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
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
            label: 'create',
            onPressed: _isCreating ? null : _submit,
            isLoading: _isCreating,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
