import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_providers.dart';
import 'package:ten_k_hours/features/sessions/data/session_providers.dart';
import 'package:ten_k_hours/features/sessions/presentation/heatmap/heatmap_painter.dart';

class HeatmapScreen extends ConsumerWidget {
  const HeatmapScreen({required this.pursuitId, super.key});
  final int pursuitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pursuitAsync = ref.watch(pursuitByIdProvider(pursuitId));
    final dailyAsync = ref.watch(dailyTotalsProvider(pursuitId));
    return Scaffold(
      appBar: AppBar(title: const Text('Heatmap')),
      body: pursuitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (pursuit) {
          if (pursuit == null) {
            return const Center(child: Text('Pursuit not found'));
          }
          final accent = Color(pursuit.accentColor);
          return dailyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (daily) => _Body(
              pursuitName: pursuit.name,
              accent: accent,
              daily: daily,
              onTapDay: (day, dur) => _showDayDetail(context, day, dur),
            ),
          );
        },
      ),
    );
  }

  void _showDayDetail(BuildContext context, DateTime day, Duration dur) {
    final fmt = DateFormat.yMMMMEEEEd();
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fmt.format(day),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  dur == Duration.zero
                      ? 'No counted sessions on this day.'
                      : '${_formatDuration(dur)} of focused work',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.pursuitName,
    required this.accent,
    required this.daily,
    required this.onTapDay,
  });

  final String pursuitName;
  final Color accent;
  final Map<DateTime, Duration> daily;
  final void Function(DateTime day, Duration total) onTapDay;

  static const _weeks = 53;
  static const _cellSize = 12.0;
  static const _cellGap = 3.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final total = daily.values.fold<Duration>(
      Duration.zero,
      (acc, d) => acc + d,
    );
    final daysActive = daily.length;
    final longest = _longestRun(daily.keys.toSet());

    const width = _weeks * (_cellSize + _cellGap);
    const height = 7 * (_cellSize + _cellGap);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pursuitName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Past year — tap a day to see details',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final pos = details.localPosition;
                  final col = pos.dx ~/ (_cellSize + _cellGap);
                  final row = pos.dy ~/ (_cellSize + _cellGap);
                  if (col < 0 || col >= _weeks || row < 0 || row >= 7) return;
                  final today = DateTime(now.year, now.month, now.day);
                  final earliest = today.subtract(
                    const Duration(days: 7 * (_weeks - 1)),
                  );
                  final earliestMonday = DateTime(
                    earliest.year,
                    earliest.month,
                    earliest.day - (earliest.weekday - 1),
                  );
                  final day = earliestMonday.add(
                    Duration(days: col * 7 + row),
                  );
                  if (day.isAfter(today)) return;
                  onTapDay(day, daily[day] ?? Duration.zero);
                },
                child: CustomPaint(
                  size: const Size(width, height),
                  painter: HeatmapPainter(
                    dailyTotals: daily,
                    accent: accent,
                    emptyColor: scheme.surfaceContainerHighest,
                    now: now,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Legend(accent: accent, emptyColor: scheme.surfaceContainerHighest),
            const SizedBox(height: 24),
            _Footer(
              total: total,
              daysActive: daysActive,
              longestRun: longest,
            ),
          ],
        ),
      ),
    );
  }

  int _longestRun(Set<DateTime> days) {
    if (days.isEmpty) return 0;
    final sorted = days.toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        run++;
        if (run > best) best = run;
      } else {
        run = 1;
      }
    }
    return best;
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.accent, required this.emptyColor});
  final Color accent;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget swatch(Color c) => Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
    return Row(
      children: [
        Text(
          'Less',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        swatch(emptyColor),
        swatch(accent.withValues(alpha: 0.25)),
        swatch(accent.withValues(alpha: 0.5)),
        swatch(accent.withValues(alpha: 0.75)),
        swatch(accent),
        const SizedBox(width: 8),
        Text(
          'More',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.total,
    required this.daysActive,
    required this.longestRun,
  });
  final Duration total;
  final int daysActive;
  final int longestRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget stat(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.textTheme.titleLarge),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final hours = total.inMinutes / 60.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        stat('hours logged', hours.toStringAsFixed(1)),
        stat('days active', '$daysActive'),
        stat('longest run', '$longestRun d'),
      ],
    );
  }
}
