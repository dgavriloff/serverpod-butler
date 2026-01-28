import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Card that lets a teacher create a new session.
class CreateSessionCard extends ConsumerStatefulWidget {
  const CreateSessionCard({super.key});

  @override
  ConsumerState<CreateSessionCard> createState() => _CreateSessionCardState();
}

class _CreateSessionCardState extends ConsumerState<CreateSessionCard> {
  final _tagController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _groupCountController = TextEditingController(text: '4');

  bool _isCreating = false;
  String? _createError;

  @override
  void dispose() {
    _tagController.dispose();
    _displayNameController.dispose();
    _groupCountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tag = _tagController.text.trim().toLowerCase();
    final displayName = _displayNameController.text.trim();
    final groupCountText = _groupCountController.text.trim();

    if (tag.length < 3 || tag.length > 30) {
      setState(() => _createError = 'session tag must be 3-30 characters');
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(tag)) {
      setState(() => _createError = 'session tag must be alphanumeric');
      return;
    }

    final groupCount = int.tryParse(groupCountText);
    if (groupCount == null || groupCount < 1 || groupCount > 50) {
      setState(() => _createError = 'group count must be between 1 and 50');
      return;
    }

    setState(() {
      _isCreating = true;
      _createError = null;
    });

    try {
      final session = await client.session.createSession(
        displayName.isNotEmpty ? displayName : tag,
        groupCount,
      );

      final liveSession = await client.session.startLiveSession(
        session.id!,
        tag,
      );

      if (!mounted) return;

      // Store creator token in a browser cookie (survives tab close / crash)
      final token = liveSession.creatorToken ?? '';
      CookieService.set('creator_$tag', token);
      context.go('/$tag');
    } catch (e) {
      if (!mounted) return;
      String message;
      if (e is ServerpodClientInternalServerError) {
        // Server throws 500 when the URL tag is already in use.
        message = 'session tag "$tag" is already in use';
      } else {
        message = friendlyError(e);
      }
      setState(() {
        _createError = message;
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
            controller: _displayNameController,
            label: 'display name',
            hint: 'optional',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: SpSpacing.sm),
          SpTextField(
            controller: _groupCountController,
            label: 'number of groups',
            hint: '4',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
          ),
          if (_createError != null) ...[
            const SizedBox(height: SpSpacing.sm),
            Text(
              _createError!,
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
