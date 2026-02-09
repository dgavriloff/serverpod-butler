import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/sp_breakpoints.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_button.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../../core/widgets/sp_markdown.dart';
import '../../../core/widgets/sp_skeleton.dart';
import '../../../main.dart';
import '../../transcript/providers/transcript_providers.dart';

/// Content tab: full-width prompt editor for student assignments.
class ContentTab extends ConsumerStatefulWidget {
  const ContentTab({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends ConsumerState<ContentTab> {
  final _promptController = TextEditingController();
  final _promptFocusNode = FocusNode();
  bool _isExtracting = false;
  Timer? _promptSaveTimer;
  bool _promptLoaded = false;
  bool _promptHovered = false;
  bool _promptFocused = false;
  bool _showPromptPreview = false;

  @override
  void initState() {
    super.initState();
    _loadPrompt();
    _promptFocusNode.addListener(_onPromptFocusChange);
  }

  void _onPromptFocusChange() {
    setState(() => _promptFocused = _promptFocusNode.hasFocus);
  }

  Future<void> _loadPrompt() async {
    try {
      final prompt = await client.butler.getPrompt(widget.sessionId);
      if (mounted && !_promptLoaded) {
        _promptController.text = prompt;
        _promptLoaded = true;
      }
    } catch (_) {
      // Ignore errors loading prompt
    }
  }

  @override
  void dispose() {
    _promptSaveTimer?.cancel();
    _promptFocusNode.removeListener(_onPromptFocusChange);
    _promptController.dispose();
    _promptFocusNode.dispose();
    super.dispose();
  }

  void _onPromptChanged(String text) {
    // Debounce saving prompt to server
    _promptSaveTimer?.cancel();
    _promptSaveTimer = Timer(const Duration(milliseconds: 500), () {
      client.butler.setPrompt(widget.sessionId, text);
    });
  }

  Future<void> _pullFromTranscript() async {
    setState(() => _isExtracting = true);
    try {
      final result = await client.butler.extractAssignment(widget.sessionId);
      if (result != null && mounted) {
        _promptController.text = result;
        await client.butler.setPrompt(widget.sessionId, result);
      }
    } catch (_) {
      // Ignore errors
    } finally {
      if (mounted) setState(() => _isExtracting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transcriptState =
        ref.watch(transcriptStateProvider(widget.sessionId));
    final screenSize = screenSizeOf(context);
    final isWide = screenSize != SpScreenSize.mobile;

    final canPull = transcriptState.hasContent && !_isExtracting;
    final isActive = _promptHovered || _promptFocused || _showPromptPreview;
    final headerText = Text('prompt', style: SpTypography.section);

    // Center the content with max width (similar to when it was 50% in two-pane)
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpSpacing.lg,
                vertical: SpSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isActive ? SpHighlight(child: headerText) : headerText,
                        const SizedBox(height: SpSpacing.xs),
                        Text(
                          'assignment for students',
                          style: SpTypography.caption
                              .copyWith(color: SpColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  // Preview/Edit toggle
                  IconButton(
                    icon: Icon(
                      _showPromptPreview ? Icons.edit : Icons.visibility,
                      size: 18,
                      color: SpColors.textSecondary,
                    ),
                    tooltip: _showPromptPreview ? 'edit' : 'preview',
                    onPressed: () =>
                        setState(() => _showPromptPreview = !_showPromptPreview),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  const SizedBox(width: SpSpacing.xs),
                  SpSecondaryButton(
                    label: 'pull from transcript',
                    icon: Icons.auto_awesome,
                    iconOnly: !isWide,
                    isLoading: _isExtracting,
                    onPressed: canPull ? _pullFromTranscript : null,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Editable prompt or preview
            Expanded(
              child: _isExtracting
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpSpacing.lg,
                        vertical: SpSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SpSkeleton(width: double.infinity, height: 16),
                          const SizedBox(height: SpSpacing.sm),
                          SpSkeleton(width: double.infinity, height: 16),
                          const SizedBox(height: SpSpacing.sm),
                          SpSkeleton(width: 200, height: 16),
                        ],
                      ),
                    )
                  : _showPromptPreview
                      ? _buildPromptPreview()
                      : MouseRegion(
                          onEnter: (_) => setState(() => _promptHovered = true),
                          onExit: (_) => setState(() => _promptHovered = false),
                          child: TextField(
                            controller: _promptController,
                            focusNode: _promptFocusNode,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: SpTypography.body,
                            decoration: InputDecoration(
                              hintText:
                                  'what should students work on? (supports markdown)',
                              hintStyle: SpTypography.body
                                  .copyWith(color: SpColors.textPlaceholder),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: SpSpacing.lg,
                                vertical: SpSpacing.md,
                              ),
                            ),
                            onChanged: _onPromptChanged,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptPreview() {
    final text = _promptController.text;
    if (text.isEmpty) {
      return Center(
        child: Text(
          'no prompt yet',
          style: SpTypography.caption.copyWith(color: SpColors.textPlaceholder),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SpSpacing.lg,
        vertical: SpSpacing.md,
      ),
      child: SpMarkdown(data: text),
    );
  }
}
