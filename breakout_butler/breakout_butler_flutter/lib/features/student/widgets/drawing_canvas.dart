import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../../../core/theme/sp_colors.dart';
import '../../../core/theme/sp_spacing.dart';

/// Freehand drawing surface using [perfect_freehand].
///
/// Each stroke is captured as a list of input points, then rendered as a
/// filled polygon via [getStroke]. Client-only — no server persistence yet.
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  final List<_Stroke> _strokes = [];
  _Stroke? _currentStroke;

  static final _strokeOptions = StrokeOptions(
    size: 4,
    thinning: 0.4,
    smoothing: 0.5,
    streamline: 0.5,
    simulatePressure: true,
  );

  void _onPointerDown(PointerDownEvent event) {
    final point = PointVector(
      event.localPosition.dx,
      event.localPosition.dy,
      event.pressure,
    );
    setState(() {
      _currentStroke = _Stroke(points: [point]);
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_currentStroke == null) return;
    final point = PointVector(
      event.localPosition.dx,
      event.localPosition.dy,
      event.pressure,
    );
    setState(() {
      _currentStroke = _Stroke(
        points: [..._currentStroke!.points, point],
      );
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_currentStroke == null) return;
    setState(() {
      _strokes.add(_currentStroke!);
      _currentStroke = null;
    });
  }

  void undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  void clear() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Canvas
        Positioned.fill(
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            child: CustomPaint(
              painter: _StrokePainter(
                strokes: _strokes,
                currentStroke: _currentStroke,
                options: _strokeOptions,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // Undo + Clear buttons (top-right)
        Positioned(
          top: SpSpacing.sm,
          right: SpSpacing.sm,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CanvasAction(
                icon: Icons.undo,
                tooltip: 'undo',
                onTap: _strokes.isNotEmpty ? undo : null,
              ),
              const SizedBox(width: SpSpacing.xs),
              _CanvasAction(
                icon: Icons.delete_outline,
                tooltip: 'clear',
                onTap: _strokes.isNotEmpty ? clear : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small icon button for canvas actions.
class _CanvasAction extends StatelessWidget {
  const _CanvasAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: SpColors.background,
            border: Border.all(color: SpColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: enabled ? SpColors.textSecondary : SpColors.textPlaceholder,
          ),
        ),
      ),
    );
  }
}

/// A single freehand stroke — raw input points.
class _Stroke {
  const _Stroke({required this.points});
  final List<PointVector> points;
}

/// Renders all strokes + the in-progress stroke as filled paths.
class _StrokePainter extends CustomPainter {
  _StrokePainter({
    required this.strokes,
    required this.currentStroke,
    required this.options,
  });

  final List<_Stroke> strokes;
  final _Stroke? currentStroke;
  final StrokeOptions options;

  @override
  void paint(Canvas canvas, Size size) {
    // White background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = SpColors.background,
    );

    final paint = Paint()
      ..color = SpColors.textPrimary
      ..style = PaintingStyle.fill;

    // Completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke.points, paint);
    }

    // In-progress stroke
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!.points, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<PointVector> points, Paint paint) {
    if (points.isEmpty) return;

    final outlinePoints = getStroke(points, options: options);
    if (outlinePoints.isEmpty) return;

    final path = ui.Path();
    path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
    for (var i = 1; i < outlinePoints.length; i++) {
      path.lineTo(outlinePoints[i].dx, outlinePoints[i].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
