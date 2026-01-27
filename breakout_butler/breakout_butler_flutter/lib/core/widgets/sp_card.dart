import 'package:flutter/material.dart';
import '../theme/sp_colors.dart';
import '../theme/sp_durations.dart';
import '../theme/sp_radius.dart';
import '../theme/sp_spacing.dart';

/// breakoutpad card — 8px radius, 1px border, 20px padding, no shadow.
///
/// Supports optional hover effect (background shifts to #F8F8F8).
class SpCard extends StatefulWidget {
  const SpCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.hoverable = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool hoverable;

  @override
  State<SpCard> createState() => _SpCardState();
}

class _SpCardState extends State<SpCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null || widget.hoverable;

    Widget card = AnimatedContainer(
      duration: SpDurations.quick,
      decoration: BoxDecoration(
        color: _hovered ? SpColors.cardHover : SpColors.background,
        borderRadius: SpRadius.cardBorder,
        border: Border.all(color: SpColors.border),
      ),
      padding: widget.padding ?? SpSpacing.cardPadding,
      child: widget.child,
    );

    if (isInteractive) {
      card = MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: card,
        ),
      );
    }

    return card;
  }
}
