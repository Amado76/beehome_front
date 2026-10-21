import 'package:flutter/material.dart';
import '../models/drawing_document.dart';

Color drawingColor(String hex) =>
    Color(int.parse('FF${hex.substring(1)}', radix: 16));

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({
    required this.strokes,
    this.pending = const [],
    this.penColor = '#2B2B2B',
    this.penWidth = 3,
    super.key,
  });
  final List<DrawingStroke> strokes;
  final List<DrawingPoint> pending;
  final String penColor;
  final double penWidth;
  static const double aspectRatio = 4 / 3;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: DrawingPainter(
      strokes: strokes,
      pending: pending,
      color: penColor,
      width: penWidth,
    ),
    child: const SizedBox.expand(),
  );
}

class DrawingPainter extends CustomPainter {
  const DrawingPainter({
    required this.strokes,
    required this.pending,
    required this.color,
    required this.width,
  });
  final List<DrawingStroke> strokes;
  final List<DrawingPoint> pending;
  final String color;
  final double width;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (final DrawingStroke stroke in strokes) {
      _paintStroke(canvas, size, stroke.points, stroke.color, stroke.width);
    }
    _paintStroke(canvas, size, pending, color, width);
    canvas.restore();
  }

  void _paintStroke(
    Canvas canvas,
    Size size,
    List<DrawingPoint> points,
    String color,
    double width,
  ) {
    if (points.isEmpty) return;
    final Paint paint = Paint()
      ..color = drawingColor(color)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final double baseWidth = width * size.width / 400;
    Offset offset(DrawingPoint point) =>
        Offset(point.x * size.width, point.y * size.height);
    if (points.length == 1) {
      canvas.drawCircle(offset(points.first), baseWidth / 2, paint);
      return;
    }
    for (int i = 1; i < points.length; i++) {
      final double pressure = points[i].pressure ?? 0.5;
      paint.strokeWidth = baseWidth * (0.5 + pressure);
      canvas.drawLine(offset(points[i - 1]), offset(points[i]), paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.pending != pending ||
      oldDelegate.color != color ||
      oldDelegate.width != width;
}
