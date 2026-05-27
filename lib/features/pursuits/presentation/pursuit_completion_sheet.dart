import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ten_k_hours/features/pursuits/domain/pursuit.dart';
import 'package:ten_k_hours/features/sessions/data/session_providers.dart';
import 'package:ten_k_hours/features/sessions/domain/session_repository.dart';
import 'package:ten_k_hours/features/sessions/domain/streaks.dart';

Future<void> showPursuitCompletionSheet(
  BuildContext context, {
  required Pursuit pursuit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: false,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => _CompletionSheet(pursuit: pursuit),
  );
}

class _CompletionSheet extends ConsumerWidget {
  const _CompletionSheet({required this.pursuit});

  final Pursuit pursuit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = Color(pursuit.accentColor);
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final streaksAsync = ref.watch(pursuitStreaksProvider(pursuit.id));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration_rounded,
                size: 56,
                color: accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You did it.',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You reached your ${_targetText(pursuit.targetMinutes)} goal '
              'on ${pursuit.name}.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            FutureBuilder<_CompletionStats>(
              future: _loadStats(sessionRepo, pursuit, streaksAsync.value),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _StatsGrid(stats: snap.data!, accent: accent);
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  String _targetText(int minutes) {
    if (minutes >= 60 && minutes % 60 == 0) return '${minutes ~/ 60}-hour';
    if (minutes < 60) return '$minutes-minute';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  Future<_CompletionStats> _loadStats(
    SessionRepository sessionRepo,
    Pursuit pursuit,
    Streaks? streaks,
  ) async {
    final total = await sessionRepo.totalCountedDurationFor(pursuit.id);
    final count = await sessionRepo.countFor(pursuit.id);
    final completed = pursuit.completedAt ?? DateTime.now().toUtc();
    final days = completed.difference(pursuit.createdAt).inDays + 1;
    final avg = count > 0
        ? Duration(milliseconds: total.inMilliseconds ~/ count)
        : Duration.zero;
    return _CompletionStats(
      totalDuration: total,
      sessions: count,
      days: days,
      longestStreak: streaks?.longestDays ?? 0,
      averageSession: avg,
    );
  }
}

class _CompletionStats {
  _CompletionStats({
    required this.totalDuration,
    required this.sessions,
    required this.days,
    required this.longestStreak,
    required this.averageSession,
  });

  final Duration totalDuration;
  final int sessions;
  final int days;
  final int longestStreak;
  final Duration averageSession;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.accent});

  final _CompletionStats stats;
  final Color accent;

  String _hms(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cells = <(String, String)>[
      ('Total time', _hms(stats.totalDuration)),
      ('Sessions', '${stats.sessions}'),
      ('Days', '${stats.days}'),
      ('Longest streak', '${stats.longestStreak}d'),
      ('Avg session', _hms(stats.averageSession)),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: cells.map((c) {
        return Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.$1.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                c.$2,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
