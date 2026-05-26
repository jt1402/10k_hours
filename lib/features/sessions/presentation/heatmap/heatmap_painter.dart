import 'package:flutter/material.dart';

class HeatmapPainter extends CustomPainter {
  HeatmapPainter({
    required this.dailyTotals,
    required this.accent,
    required this.emptyColor,
    required this.now,
    this.weeks = 53,
    this.cellSize = 12,
    this.cellGap = 3,
  });

  final Map<DateTime, Duration> dailyTotals;
  final Color accent;
  final Color emptyColor;
  final DateTime now;
  final int weeks;
  final double cellSize;
  final double cellGap;

  static const _intensityThresholdsMin = <int>[30, 60, 120];

  @override
  void paint(Canvas canvas, Size size) {
    final today = DateTime(now.year, now.month, now.day);
    // Earliest column = (weeks-1) weeks back from today, aligned to Monday.
    final earliest = today.subtract(Duration(days: 7 * (weeks - 1)));
    final earliestMonday = _mondayOf(earliest);

    final paint = Paint()..style = PaintingStyle.fill;
    for (var col = 0; col < weeks; col++) {
      for (var row = 0; row < 7; row++) {
        final day = earliestMonday.add(Duration(days: col * 7 + row));
        if (day.isAfter(today)) continue;
        final dur = dailyTotals[day] ?? Duration.zero;
        paint.color = _colorForDuration(dur);
        final dx = col * (cellSize + cellGap);
        final dy = row * (cellSize + cellGap);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(dx, dy, cellSize, cellSize),
            const Radius.circular(2.5),
          ),
          paint,
        );
      }
    }
  }

  Color _colorForDuration(Duration d) {
    if (d.inMinutes == 0) return emptyColor;
    if (d.inMinutes < _intensityThresholdsMin[0]) {
      return accent.withValues(alpha: 0.25);
    }
    if (d.inMinutes < _intensityThresholdsMin[1]) {
      return accent.withValues(alpha: 0.5);
    }
    if (d.inMinutes < _intensityThresholdsMin[2]) {
      return accent.withValues(alpha: 0.75);
    }
    return accent;
  }

  DateTime _mondayOf(DateTime d) {
    // Dart's DateTime.weekday: 1 = Monday … 7 = Sunday.
    return DateTime(d.year, d.month, d.day - (d.weekday - 1));
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter old) =>
      old.dailyTotals != dailyTotals ||
      old.accent != accent ||
      old.emptyColor != emptyColor ||
      old.now != now ||
      old.weeks != weeks ||
      old.cellSize != cellSize ||
      old.cellGap != cellGap;
}
