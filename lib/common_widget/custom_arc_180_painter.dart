import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import '../common/color_extension.dart';


class ArcValueModel {
  final Color color;
  final double value;

  ArcValueModel({required this.color, required this.value});
}

class CustomArc180Painter extends CustomPainter {
  final double totalBudget;
  final double usedBudget;
  final double width;
  final double bgWidth;
  final double blurWidth;

  CustomArc180Painter({
    required this.totalBudget,
    required this.usedBudget,
    this.width = 15,
    this.bgWidth = 10,
    this.blurWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Paint for background arc
    final bgPaint = Paint()
      ..color = TColor.gray60.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = bgWidth
      ..strokeCap = StrokeCap.round;

    // Draw full 180° background arc
    canvas.drawArc(rect, radians(180), radians(180), false, bgPaint);

    if (usedBudget <= 0 || totalBudget <= 0) return;

    final usedPercent = (usedBudget / totalBudget).clamp(0.0, 1.0);
    final usedDegrees = 180 * usedPercent;
    final safeLimit = 0.75;
    final safeDegrees = 180 * safeLimit;

    double startAngle = radians(180); // Starting from 180°

    if (usedPercent <= safeLimit) {
      // Paint full green arc
      _drawArcSegment(
        canvas,
        rect,
        startAngle,
        radians(usedDegrees),
        TColor.line,
      );
    } else {
      // Green segment up to 75%
      _drawArcSegment(
        canvas,
        rect,
        startAngle,
        radians(safeDegrees),
        TColor.line,
      );

      // Red segment for overflow (after 75%)
      final redStartAngle = startAngle + radians(safeDegrees);
      final redSweepAngle = radians(usedDegrees - safeDegrees);

      _drawArcSegment(
        canvas,
        rect,
        redStartAngle,
        redSweepAngle,
        TColor.secondary,
      );
    }
  }

  void _drawArcSegment(Canvas canvas, Rect rect, double start, double sweep, Color color) {
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + blurWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final path = Path()..addArc(rect, start, sweep);
    canvas.drawPath(path, shadowPaint);
    canvas.drawArc(rect, start, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(CustomArc180Painter oldDelegate) =>
      oldDelegate.usedBudget != usedBudget ||
          oldDelegate.totalBudget != totalBudget;

  @override
  bool shouldRebuildSemantics(CustomArc180Painter oldDelegate) => false;
}

