import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/sp_colors.dart';

/// Abstract dot-pattern illustration for the landing page left pane.
///
/// Renders scattered circles in soft blue and gray behind the hero card.
class LandingIllustration extends StatelessWidget {
  const LandingIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotPatternPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  // Fixed seed so the pattern is deterministic across rebuilds.
  static final _rng = Random(42);

  // Pre-generated dot definitions (relative x, y, radius, color index).
  static final _dots = List.generate(18, (_) {
    return _DotDef(
      rx: _rng.nextDouble(),
      ry: _rng.nextDouble(),
      radius: 4.0 + _rng.nextDouble() * 20.0,
      colorIndex: _rng.nextInt(3),
    );
  });

  static const _colors = [
    Color(0x152196F3), // soft blue
    Color(0x10E0E0E0), // light gray
    Color(0x0CFFC107), // faint yellow
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final dot in _dots) {
      final paint = Paint()..color = _colors[dot.colorIndex];
      canvas.drawCircle(
        Offset(dot.rx * size.width, dot.ry * size.height),
        dot.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotDef {
  const _DotDef({
    required this.rx,
    required this.ry,
    required this.radius,
    required this.colorIndex,
  });

  final double rx;
  final double ry;
  final double radius;
  final int colorIndex;
}
