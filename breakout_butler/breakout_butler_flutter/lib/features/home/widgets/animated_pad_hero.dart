import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';
import '../../../core/theme/sp_typography.dart';
import '../../../core/widgets/sp_card.dart';
import '../../student/widgets/drawing_canvas.dart';

/// Editor mode for the hero demo.
enum _HeroMode { write, draw }

/// Animated hero card that mimics a collaborative editor typing out the app
/// title and features. Plays once on page load.
class AnimatedPadHero extends StatefulWidget {
  const AnimatedPadHero({super.key});

  @override
  State<AnimatedPadHero> createState() => _AnimatedPadHeroState();
}

class _AnimatedPadHeroState extends State<AnimatedPadHero>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────────
  late final AnimationController _sequenceController;
  late final AnimationController _cursorController;

  // ── Content to type ────────────────────────────────────────────────────
  static const _title = 'breakoutpad';
  static const _subtitle = 'instant collaborative surfaces';
  static const _features = [
    (icon: Icons.groups, text: 'real-time breakout rooms'),
    (icon: Icons.auto_awesome, text: 'ai-powered scribe assistant'),
    (icon: Icons.flash_on, text: 'zero setup, instant start'),
  ];

  // ── Timing constants (milliseconds) ────────────────────────────────────
  static const _charDelay = 40;
  static const _pauseDuration = 400;

  // Timeline markers (cumulative ms)
  late final int _titleEnd;
  late final int _subtitleStart;
  late final int _subtitleEnd;
  late final int _feature1Start;
  late final int _feature1End;
  late final int _feature2Start;
  late final int _feature2End;
  late final int _feature3Start;
  late final int _feature3End;
  late final int _savingStart;
  late final int _savedStart;
  late final int _totalDuration;

  // ── Current display state ──────────────────────────────────────────────
  String _displayTitle = '';
  String _displaySubtitle = '';
  final List<String> _displayFeatures = ['', '', ''];
  bool _showSaving = false;
  bool _showSaved = false;
  bool _cursorVisible = true;
  int _cursorPosition = 0; // 0=title, 1=subtitle, 2/3/4=features, 5=done

  // ── Interactive state (after animation) ────────────────────────────────
  bool _animationComplete = false;
  _HeroMode _mode = _HeroMode.write;

  @override
  void initState() {
    super.initState();

    // Calculate timeline
    _titleEnd = _title.length * _charDelay;
    _subtitleStart = _titleEnd + _pauseDuration;
    _subtitleEnd = _subtitleStart + _subtitle.length * _charDelay;
    _feature1Start = _subtitleEnd + _pauseDuration;
    _feature1End = _feature1Start + _features[0].text.length * _charDelay;
    _feature2Start = _feature1End + 300;
    _feature2End = _feature2Start + _features[1].text.length * _charDelay;
    _feature3Start = _feature2End + 300;
    _feature3End = _feature3Start + _features[2].text.length * _charDelay;
    _savingStart = _feature3End + 200;
    _savedStart = _savingStart + 300;
    _totalDuration = _savedStart + 300;

    // Main sequence controller
    _sequenceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalDuration),
    )
      ..addListener(_updateDisplay)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _animationComplete = true);
        }
      });

    // Cursor blink controller
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _cursorController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _cursorController.forward();
        }
      });

    _cursorController.addListener(() {
      if (!_showSaved) {
        setState(() => _cursorVisible = _cursorController.value > 0.5);
      }
    });

    // Start animations
    _sequenceController.forward();
    _cursorController.forward();
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  void _updateDisplay() {
    final elapsed =
        (_sequenceController.value * _totalDuration).round();

    setState(() {
      // Title
      if (elapsed < _titleEnd) {
        final chars = (elapsed / _charDelay).floor();
        _displayTitle = _title.substring(0, chars.clamp(0, _title.length));
        _cursorPosition = 0;
      } else {
        _displayTitle = _title;
      }

      // Subtitle
      if (elapsed >= _subtitleStart && elapsed < _subtitleEnd) {
        final chars = ((elapsed - _subtitleStart) / _charDelay).floor();
        _displaySubtitle =
            _subtitle.substring(0, chars.clamp(0, _subtitle.length));
        _cursorPosition = 1;
      } else if (elapsed >= _subtitleEnd) {
        _displaySubtitle = _subtitle;
      }

      // Feature 1
      if (elapsed >= _feature1Start && elapsed < _feature1End) {
        final chars = ((elapsed - _feature1Start) / _charDelay).floor();
        _displayFeatures[0] = _features[0]
            .text
            .substring(0, chars.clamp(0, _features[0].text.length));
        _cursorPosition = 2;
      } else if (elapsed >= _feature1End) {
        _displayFeatures[0] = _features[0].text;
      }

      // Feature 2
      if (elapsed >= _feature2Start && elapsed < _feature2End) {
        final chars = ((elapsed - _feature2Start) / _charDelay).floor();
        _displayFeatures[1] = _features[1]
            .text
            .substring(0, chars.clamp(0, _features[1].text.length));
        _cursorPosition = 3;
      } else if (elapsed >= _feature2End) {
        _displayFeatures[1] = _features[1].text;
      }

      // Feature 3
      if (elapsed >= _feature3Start && elapsed < _feature3End) {
        final chars = ((elapsed - _feature3Start) / _charDelay).floor();
        _displayFeatures[2] = _features[2]
            .text
            .substring(0, chars.clamp(0, _features[2].text.length));
        _cursorPosition = 4;
      } else if (elapsed >= _feature3End) {
        _displayFeatures[2] = _features[2].text;
      }

      // Save indicator
      if (elapsed >= _savingStart && elapsed < _savedStart) {
        _showSaving = true;
        _cursorPosition = 5;
      } else if (elapsed >= _savedStart) {
        _showSaving = false;
        _showSaved = true;
        _cursorPosition = 5;
        _cursorVisible = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SpCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // ── Content layer ─────────────────────────────────────────────
          Padding(
            padding: SpSpacing.cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Save indicator (top-right aligned)
                Align(
                  alignment: Alignment.centerRight,
                  child: _SaveIndicator(
                    showSaving: _showSaving,
                    showSaved: _showSaved,
                  ),
                ),
                const SizedBox(height: SpSpacing.sm),

                // Title
                _TypewriterText(
                  text: _displayTitle,
                  style: SpTypography.display,
                  showCursor: _cursorPosition == 0 && _cursorVisible,
                ),
                const SizedBox(height: SpSpacing.sm),

                // Subtitle
                _TypewriterText(
                  text: _displaySubtitle,
                  style: SpTypography.body.copyWith(color: SpColors.textSecondary),
                  showCursor: _cursorPosition == 1 && _cursorVisible,
                ),
                const SizedBox(height: SpSpacing.lg),

                // Features
                for (var i = 0; i < _features.length; i++) ...[
                  if (i > 0) const SizedBox(height: SpSpacing.sm),
                  _AnimatedFeatureBullet(
                    icon: _features[i].icon,
                    text: _displayFeatures[i],
                    showCursor: _cursorPosition == (i + 2) && _cursorVisible,
                  ),
                ],

                const SizedBox(height: SpSpacing.lg),

                // Mode selector (interactive after animation)
                _ModeSelector(
                  currentMode: _mode,
                  enabled: _animationComplete,
                  onChanged: (mode) => setState(() => _mode = mode),
                ),
              ],
            ),
          ),

          // ── Drawing layer (on top, only active in draw mode) ──────────
          Positioned.fill(
            child: DrawingCanvas(
              interactive: _animationComplete && _mode == _HeroMode.draw,
            ),
          ),
        ],
      ),
    );
  }
}

/// Text with optional blinking cursor at the end.
class _TypewriterText extends StatelessWidget {
  const _TypewriterText({
    required this.text,
    required this.style,
    required this.showCursor,
  });

  final String text;
  final TextStyle style;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text, style: style),
          if (showCursor)
            TextSpan(
              text: '|',
              style: style.copyWith(
                color: SpColors.primaryAction,
                fontWeight: FontWeight.w300,
              ),
            ),
        ],
      ),
    );
  }
}

/// Feature bullet with icon and typewriter text.
class _AnimatedFeatureBullet extends StatelessWidget {
  const _AnimatedFeatureBullet({
    required this.icon,
    required this.text,
    required this.showCursor,
  });

  final IconData icon;
  final String text;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    // Only show icon when text starts appearing
    final showIcon = text.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          opacity: showIcon ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: Icon(icon, size: 20, color: SpColors.primaryAction),
        ),
        const SizedBox(width: SpSpacing.sm),
        _TypewriterText(
          text: text,
          style: SpTypography.body,
          showCursor: showCursor,
        ),
      ],
    );
  }
}

/// Animated saving.../saved indicator.
class _SaveIndicator extends StatelessWidget {
  const _SaveIndicator({
    required this.showSaving,
    required this.showSaved,
  });

  final bool showSaving;
  final bool showSaved;

  @override
  Widget build(BuildContext context) {
    final visible = showSaving || showSaved;

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: showSaved ? SpColors.success : SpColors.textPlaceholder,
            ),
          ),
          const SizedBox(width: SpSpacing.xs),
          Text(
            showSaved ? 'saved' : 'saving...',
            style: SpTypography.caption.copyWith(
              color: SpColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Write/draw toggle — interactive after animation completes.
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.currentMode,
    required this.enabled,
    required this.onChanged,
  });

  final _HeroMode currentMode;
  final bool enabled;
  final ValueChanged<_HeroMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeLabel(
          label: 'write',
          isSelected: currentMode == _HeroMode.write,
          onTap: enabled ? () => onChanged(_HeroMode.write) : null,
        ),
        const SizedBox(width: SpSpacing.md),
        _ModeLabel(
          label: 'draw',
          isSelected: currentMode == _HeroMode.draw,
          onTap: enabled ? () => onChanged(_HeroMode.draw) : null,
        ),
      ],
    );
  }
}

/// Individual mode label with yellow highlight when selected.
class _ModeLabel extends StatelessWidget {
  const _ModeLabel({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpSpacing.xs,
            vertical: SpSpacing.xs,
          ),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              // Yellow highlight underline
              if (isSelected)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 1,
                  height: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: SpColors.highlight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              Text(
                label,
                style: SpTypography.body.copyWith(
                  color: isSelected ? SpColors.textPrimary : SpColors.textTertiary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
