import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ten_k_hours/core/theme/typography.dart';
import 'package:ten_k_hours/features/sessions/presentation/ring/ring_painter.dart';

class RingWidget extends StatelessWidget {
  const RingWidget({
    required this.elapsed,
    required this.targetMinutes,
    required this.accent,
    this.completed = false,
    this.size = 280,
    super.key,
  });

  final Duration elapsed;
  final int targetMinutes;
  final Color accent;
  final bool completed;
  final double size;

  Duration get _target => Duration(minutes: targetMinutes);

  double get _progress {
    if (_target.inMilliseconds == 0) return 0;
    return (elapsed.inMilliseconds / _target.inMilliseconds).clamp(0, 1);
  }

  Duration get _remaining {
    final r = _target - elapsed;
    return r.isNegative ? Duration.zero : r;
  }

  // Sub-1h targets show MM:SS remaining (live tick happens at parent's ticker
  // since this widget rebuilds on every elapsed change). Multi-hour targets
  // show H:MM (or just the hour count when >= 100h).
  String _formatRemaining() {
    if (targetMinutes < 60) {
      final m = _remaining.inMinutes;
      final s = _remaining.inSeconds % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    final totalMinutes = _remaining.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours >= 100) {
      return NumberFormat('#,##0').format(hours);
    }
    final mm = minutes.toString().padLeft(2, '0');
    return '$hours:$mm';
  }

  String _remainingLabel() {
    if (targetMinutes < 60) return 'minutes : seconds left';
    final h = _remaining.inMinutes ~/ 60;
    return h >= 100 ? 'hours left' : 'hours : minutes left';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final remainingHours = _remaining.inMinutes ~/ 60;
    final ringFontSize = remainingHours >= 1000 ? 72.0 : 88.0;
    return Semantics(
      label:
          '${_remaining.inMinutes} minutes remaining '
          'of $targetMinutes minute target',
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
            if (completed)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 96,
                    color: accent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completed',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatRemaining(),
                    style: ringNumberStyle(scheme, size: ringFontSize),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _remainingLabel(),
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
