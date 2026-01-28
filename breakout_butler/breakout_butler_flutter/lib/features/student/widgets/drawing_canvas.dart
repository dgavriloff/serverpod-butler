import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../../../core/theme/sp_colors.dart';

// ── JS interop for localStorage (WASM-safe) ────────────────────────

JSObject get _localStorage =>
    globalContext.getProperty('localStorage'.toJS) as JSObject;

String? _storageGet(String key) {
  final result =
      _localStorage.callMethod('getItem'.toJS, key.toJS) as JSString?;
  return result?.toDart;
}

void _storageSet(String key, String value) {
  _localStorage.callMethod('setItem'.toJS, key.toJS, value.toJS);
}

// ────────────────────────────────────────────────────────────────────

/// Freehand drawing surface using [perfect_freehand].
///
/// Each stroke is captured as a list of input points, then rendered as a
/// filled polygon via [getStroke]. Persists to browser localStorage.
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key, required this.storageKey});

  /// Key used to persist strokes in localStorage (e.g. "drawing_1_2").
  final String storageKey;

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

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  // ── Persistence ──────────────────────────────────────────────────

  void _loadFromStorage() {
    try {
      final json = _storageGet(widget.storageKey);
      if (json == null || json.isEmpty) return;
      final list = jsonDecode(json) as List<dynamic>;
      for (final strokeJson in list) {
        final points = (strokeJson as List<dynamic>)
            .map((p) => PointVector(
                  (p[0] as num).toDouble(),
                  (p[1] as num).toDouble(),
                  (p[2] as num).toDouble(),
                ))
            .toList();
        _strokes.add(_Stroke(points: points));
      }
    } catch (_) {
      // Corrupt data — start fresh.
    }
  }

  void _saveToStorage() {
    try {
      final data = _strokes
          .map((s) => s.points.map((p) => [p.x, p.y, p.pressure]).toList())
          .toList();
      _storageSet(widget.storageKey, jsonEncode(data));
    } catch (_) {
      // Storage full or unavailable — silent fail.
    }
  }

  // ── Pointer handling ─────────────────────────────────────────────

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
    _saveToStorage();
  }

  void undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
    _saveToStorage();
  }

  void clear() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.clear());
    _saveToStorage();
  }

  bool get hasStrokes => _strokes.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Listener(
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
