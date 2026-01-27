import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_ai_card.dart';
import '../../../core/widgets/sp_skeleton.dart';
import '../../../core/widgets/sp_text_field.dart';
import '../../butler/providers/butler_providers.dart';

/// Input field + inline response for asking the butler.
///
/// "ASK BUTLER" overline label. Response appears inline as [SpAiCard].
class ButlerInput extends ConsumerStatefulWidget {
  const ButlerInput({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<ButlerInput> createState() => _ButlerInputState();
}

class _ButlerInputState extends ConsumerState<ButlerInput> {
  final _controller = TextEditingController();
  String? _lastAnswer;
  bool _isAsking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() => _isAsking = true);
    try {
      final response = await ref
          .read(butlerActionsProvider.notifier)
          .askButler(widget.sessionId, question);
      if (mounted) {
        setState(() {
          _lastAnswer = response.answer;
          _isAsking = false;
        });
        _controller.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAsking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpSpacing.md),
          child: Text(
            'ASK BUTLER',
            style: SpTypography.overline.copyWith(
              color: SpColors.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: SpSpacing.xs),

        // Input row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: SpTextField(
                  controller: _controller,
                  hint: 'ask a question...',
                  onSubmitted: (_) => _ask(),
                ),
              ),
              const SizedBox(width: SpSpacing.sm),
              IconButton(
                icon: const Icon(Icons.send, size: 20),
                onPressed: _isAsking ? null : _ask,
              ),
            ],
          ),
        ),

        // Response
        if (_isAsking)
          const Padding(
            padding: EdgeInsets.all(SpSpacing.sm),
            child: SpAiCard(
              header: 'thinking...',
              child: SpSkeleton(height: 48),
            ),
          )
        else if (_lastAnswer != null)
          Padding(
            padding: const EdgeInsets.all(SpSpacing.sm),
            child: SpAiCard(
              header: 'butler',
              child: Text(_lastAnswer!, style: SpTypography.body),
            ),
          ),
      ],
    );
  }
}
