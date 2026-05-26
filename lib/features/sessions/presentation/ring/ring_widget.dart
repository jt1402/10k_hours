import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ten_k_hours/core/theme/typography.dart';
import 'package:ten_k_hours/features/sessions/presentation/ring/ring_painter.dart';

class RingWidget extends StatelessWidget {
  const RingWidget({
    required this.elapsed,
    required this.targetHours,
    required this.accent,
    this.size = 280,
    super.key,
  });

  final Duration elapsed;
  final int targetHours;
  final Color accent;
  final double size;

  Duration get _target => Duration(hours: targetHours);

  double get _progress {
    if (_target.inMilliseconds == 0) return 0;
    return (elapsed.inMilliseconds / _target.inMilliseconds).clamp(0, 1);
  }

  Duration get _remaining {
    final r = _target - elapsed;
    return r.isNegative ? Duration.zero : r;
  }

  String _formatRemaining() {
    final totalMinutes = _remaining.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours >= 100) {
      return NumberFormat('#,##0').format(hours);
    }
    final mm = minutes.toString().padLeft(2, '0');
    return '$hours:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final remainingHours = _remaining.inMinutes ~/ 60;
    final ringFontSize = remainingHours >= 1000 ? 72.0 : 88.0;
    return Semantics(
      label:
          '${_remaining.inHours} hours remaining of $targetHours hour target',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: RingPainter(
                progress: _progress,
                accent: accent,
                backdrop: scheme.surfaceContainerHighest,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatRemaining(),
                  style: ringNumberStyle(scheme, size: ringFontSize),
                ),
                const SizedBox(height: 4),
                Text(
                  remainingHours >= 100 ? 'hours left' : 'hours : minutes left',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
