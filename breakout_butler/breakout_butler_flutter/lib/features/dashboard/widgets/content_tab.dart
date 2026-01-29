import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/sp_breakpoints.dart';
import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_button.dart';
import '../../../core/widgets/sp_highlight.dart';
import '../../../core/widgets/sp_skeleton.dart';
import '../../../main.dart';
import '../../transcript/providers/recording_providers.dart';
import '../../transcript/providers/transcript_providers.dart';

/// Content tab: two-column layout with prompt (left) and transcript (right).
class ContentTab extends ConsumerStatefulWidget {
  const ContentTab({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends ConsumerState<ContentTab> {
  final _promptController = TextEditingController();
  final _transcriptController = TextEditingController();
  final _promptFocusNode = FocusNode();
  final _transcriptFocusNode = FocusNode();
  bool _isExtracting = false;
  Timer? _promptSaveTimer;
  bool _promptLoaded = false;
  bool _promptHovered = false;
  bool _promptFocused = false;
  bool _transcriptHovered = false;
  bool _transcriptFocused = false;

  @override
  void initState() {
    super.initState();
    _loadPrompt();
    _promptFocusNode.addListener(_onPromptFocusChange);
    _transcriptFocusNode.addListener(_onTranscriptFocusChange);
  }

  void _onPromptFocusChange() {
    setState(() => _promptFocused = _promptFocusNode.hasFocus);
  }

  void _onTranscriptFocusChange() {
    setState(() => _transcriptFocused = _transcriptFocusNode.hasFocus);
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
    _transcriptFocusNode.removeListener(_onTranscriptFocusChange);
    _promptController.dispose();
    _transcriptController.dispose();
    _promptFocusNode.dispose();
    _transcriptFocusNode.dispose();
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
      // Sync local transcript to server first
      final transcriptText = _transcriptController.text.trim();
      if (transcriptText.isNotEmpty) {
        await client.butler.setTranscript(widget.sessionId, transcriptText);
      }

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
    final recordingState =
        ref.watch(recordingControllerProvider(widget.sessionId));
    final screenSize = screenSizeOf(context);
    final isWide = screenSize != SpScreenSize.mobile;

    // Sync transcript controller when not recording and chunks change
    if (!recordingState.isRecording) {
      final fullText = transcriptState.fullText;
      if (_transcriptController.text != fullText) {
        _transcriptController.text = fullText;
      }
    }

    // Two-column on tablet/desktop, stacked on mobile
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Prompt
          Expanded(
            flex: 1,
            child: _buildPromptSection(transcriptState.hasContent),
          ),
          const VerticalDivider(width: 1),
          // Right column: Transcript
          Expanded(
            flex: 1,
            child: _buildTranscriptSection(
              transcriptState,
              recordingState.isRecording,
            ),
          ),
        ],
      );
    }

    // Mobile: stacked
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromptSection(transcriptState.hasContent),
          const SizedBox(height: SpSpacing.lg),
          SizedBox(
            height: 400,
            child: _buildTranscriptSection(
              transcriptState,
              recordingState.isRecording,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSection(bool hasTranscript) {
    final canPull = hasTranscript && !_isExtracting;
    final isActive = _promptHovered || _promptFocused;
    final headerText = Text('prompt', style: SpTypography.section);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(SpSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isActive ? SpHighlight(child: headerText) : headerText,
              const SizedBox(height: SpSpacing.xs),
              Text(
                'assignment for students',
                style:
                    SpTypography.caption.copyWith(color: SpColors.textTertiary),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Editable prompt with floating button
        Expanded(
          child: Stack(
            children: [
              // Text field takes full area
              _isExtracting
                  ? Padding(
                      padding: const EdgeInsets.all(SpSpacing.md),
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
                  : MouseRegion(
                      onEnter: (_) => setState(() => _promptHovered = true),
                      onExit: (_) => setState(() => _promptHovered = false),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: SpSpacing.md),
                        child: TextField(
                          controller: _promptController,
                          focusNode: _promptFocusNode,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: SpTypography.body,
                          decoration: InputDecoration(
                            hintText: 'what should students work on?',
                            hintStyle: SpTypography.body
                                .copyWith(color: SpColors.textPlaceholder),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.all(SpSpacing.md),
                          ),
                          onChanged: _onPromptChanged,
                        ),
                      ),
                    ),
              // Floating button in top-right
              Positioned(
                top: SpSpacing.sm,
                right: SpSpacing.md,
                child: SpSecondaryButton(
                  label: 'pull from transcript',
                  icon: Icons.auto_awesome,
                  isLoading: _isExtracting,
                  onPressed: canPull ? _pullFromTranscript : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptSection(
    TranscriptState transcriptState,
    bool isRecording,
  ) {
    // When recording, always show highlight (it's active)
    final isActive = isRecording || _transcriptHovered || _transcriptFocused;
    final headerText = Text('transcript', style: SpTypography.section);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(SpSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  isActive ? SpHighlight(child: headerText) : headerText,
                  if (isRecording) ...[
                    const SizedBox(width: SpSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: SpColors.live.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'recording',
                        style: SpTypography.caption.copyWith(
                          color: SpColors.live,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: SpSpacing.xs),
              Text(
                isRecording
                    ? 'listening to lecture...'
                    : 'type or record lecture content',
                style:
                    SpTypography.caption.copyWith(color: SpColors.textTertiary),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Transcript content - editable when not recording
        Expanded(
          child: isRecording
              ? _buildLiveTranscript(transcriptState)
              : _buildEditableTranscript(),
        ),
      ],
    );
  }

  Widget _buildLiveTranscript(TranscriptState transcriptState) {
    if (!transcriptState.hasContent) {
      return Center(
        child: Text(
          'waiting for speech...',
          style: SpTypography.caption.copyWith(color: SpColors.textPlaceholder),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(SpSpacing.md),
      itemCount: transcriptState.chunks.length +
          (transcriptState.interimText.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < transcriptState.chunks.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: SpSpacing.sm),
            child: Text(
              transcriptState.chunks[index],
              style: SpTypography.body,
            ),
          );
        }
        // Interim text
        return Text(
          transcriptState.interimText,
          style: SpTypography.body.copyWith(
            fontStyle: FontStyle.italic,
            color: SpColors.textTertiary,
          ),
        );
      },
    );
  }

  Widget _buildEditableTranscript() {
    return MouseRegion(
      onEnter: (_) => setState(() => _transcriptHovered = true),
      onExit: (_) => setState(() => _transcriptHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpSpacing.md),
        child: TextField(
          controller: _transcriptController,
          focusNode: _transcriptFocusNode,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: SpTypography.body,
          decoration: InputDecoration(
            hintText: 'paste or type lecture content here...',
            hintStyle:
                SpTypography.body.copyWith(color: SpColors.textPlaceholder),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.all(SpSpacing.md),
          ),
          onChanged: (text) {
            // Update transcript state when user edits
            ref
                .read(transcriptStateProvider(widget.sessionId).notifier)
                .setFullText(text);
          },
        ),
      ),
    );
  }
}
