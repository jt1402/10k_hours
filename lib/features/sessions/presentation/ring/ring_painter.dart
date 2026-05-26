import 'dart:math' as math;

import 'package:flutter/material.dart';

class RingPainter extends CustomPainter {
  RingPainter({
    required this.progress,
    required this.accent,
    required this.backdrop,
    this.strokeWidth = 20,
  });

  final double progress;
  final Color accent;
  final Color backdrop;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bg = Paint()
      ..color = backdrop
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bg);

    final clamped = progress.clamp(0.0, 1.0);
    if (clamped > 0) {
      final fg = Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      const startAngle = -math.pi / 2;
      final sweep = 2 * math.pi * clamped;
      canvas.drawArc(rect, startAngle, sweep, false, fg);
    }
  }

  @override
  bool shouldRepaint(covariant RingPainter old) =>
      old.progress != progress ||
      old.accent != accent ||
      old.backdrop != backdrop ||
      old.strokeWidth != strokeWidth;
}
