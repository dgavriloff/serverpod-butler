import 'dart:math';

import 'package:flutter/material.dart';

/// Abstract dot-pattern illustration for the landing page left pane.
///
/// Renders scattered circles in soft colors. Dots drift subtly in response
/// to the mouse cursor position (parallax effect).
class LandingIllustration extends StatefulWidget {
  const LandingIllustration({super.key});

  @override
  State<LandingIllustration> createState() => _LandingIllustrationState();
}

class _LandingIllustrationState extends State<LandingIllustration> {
  /// Normalized mouse offset from center: (-1,-1) top-left to (1,1) bottom-right.
  Offset _mouseOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final size = context.size;
        if (size == null || size.isEmpty) return;
        setState(() {
          _mouseOffset = Offset(
            (event.localPosition.dx / size.width - 0.5) * 2.0,
            (event.localPosition.dy / size.height - 0.5) * 2.0,
          );
        });
      },
      onExit: (_) => setState(() => _mouseOffset = Offset.zero),
      child: CustomPaint(
        painter: _DotPatternPainter(_mouseOffset),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  _DotPatternPainter(this.mouseOffset);

  final Offset mouseOffset;

  // Fixed seed so the pattern is deterministic across rebuilds.
  static final _rng = Random(42);

  // Pre-generated dot definitions: relative position, radius, color, parallax depth.
  static final _dots = List.generate(40, (_) {
    return _DotDef(
      rx: _rng.nextDouble(),
      ry: _rng.nextDouble(),
      radius: 3.0 + _rng.nextDouble() * 24.0,
      colorIndex: _rng.nextInt(3),
      // Depth: 0.0 = no movement, 1.0 = max parallax. Larger dots move more.
      depth: 0.2 + _rng.nextDouble() * 0.8,
    );
  });

  static const _colors = [
    Color(0x182196F3), // soft blue
    Color(0x12E0E0E0), // light gray
    Color(0x10FFC107), // faint yellow
  ];

  /// Max pixel offset at full mouse displacement.
  static const _maxShift = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    for (final dot in _dots) {
      final shift = _maxShift * dot.depth;
      final dx = dot.rx * size.width + mouseOffset.dx * shift;
      final dy = dot.ry * size.height + mouseOffset.dy * shift;

      final paint = Paint()..color = _colors[dot.colorIndex];
      canvas.drawCircle(Offset(dx, dy), dot.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter oldDelegate) =>
      oldDelegate.mouseOffset != mouseOffset;
}

class _DotDef {
  const _DotDef({
    required this.rx,
    required this.ry,
    required this.radius,
    required this.colorIndex,
    required this.depth,
  });

  final double rx;
  final double ry;
  final double radius;
  final int colorIndex;
  final double depth;
}
