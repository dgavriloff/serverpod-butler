import 'package:flutter/material.dart';
import '../theme/sp_colors.dart';

/// Wraps a text widget with a yellow marker-style highlight behind
/// the bottom ~35% of the text, like a highlighter pen.
///
/// Used only on prominent text: breadcrumbs, section headers, big numbers.
class SpHighlight extends StatelessWidget {
  const SpHighlight({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 1,
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: SpColors.highlight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
