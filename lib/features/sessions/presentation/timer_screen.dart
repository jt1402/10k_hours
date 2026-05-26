import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_providers.dart';
import 'package:ten_k_hours/features/pursuits/domain/pursuit.dart';
import 'package:ten_k_hours/features/sessions/data/session_providers.dart';
import 'package:ten_k_hours/features/sessions/domain/active_session.dart';
import 'package:ten_k_hours/features/sessions/domain/streaks.dart';
import 'package:ten_k_hours/features/sessions/presentation/ring/ring_widget.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({required this.pursuitId, super.key});
  final int pursuitId;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  Timer? _ticker;
  int _lastWholeHoursElapsed = -1;

  void _ensureTicker(bool needTicker) {
    if (needTicker && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!needTicker && _ticker != null) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration _currentSessionElapsed(ActiveSession? active) {
    if (active == null) return Duration.zero;
    return active.elapsedAt(DateTime.now().toUtc());
  }

  Future<void> _onTap(ActiveSession? active) async {
    final service = ref.read(sessionServiceProvider);
    if (active == null) {
      await service.start(widget.pursuitId);
      unawaited(HapticFeedback.lightImpact());
    } else if (active.isPaused) {
      await service.resume();
      unawaited(HapticFeedback.lightImpact());
    } else {
      await service.pause();
      unawaited(HapticFeedback.lightImpact());
    }
  }

  Future<void> _onLongPress(ActiveSession? active) async {
    if (active == null) return;
    final service = ref.read(sessionServiceProvider);
    final result = await service.stop();
    unawaited(HapticFeedback.mediumImpact());
    _lastWholeHoursElapsed = -1;
    if (!mounted) return;
    if (!result.countedTowardStats) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session too short to count (under 1 min)'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _maybeHourBoundaryHaptic(Duration totalElapsed) {
    final hours = totalElapsed.inHours;
    if (_lastWholeHoursElapsed < 0) {
      _lastWholeHoursElapsed = hours;
      return;
    }
    if (hours > _lastWholeHoursElapsed) {
      _lastWholeHoursElapsed = hours;
      unawaited(HapticFeedback.heavyImpact());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pursuitAsync = ref.watch(pursuitByIdProvider(widget.pursuitId));
    final activeAsync = ref.watch(activeSessionProvider);
    final totalAsync = ref.watch(
      totalCountedDurationProvider(widget.pursuitId),
    );
    final streaksAsync = ref.watch(pursuitStreaksProvider(widget.pursuitId));

    final active = activeAsync.value;
    final isThisPursuit = active?.pursuitId == widget.pursuitId;
    final activeForThis = isThisPursuit ? active : null;
    _ensureTicker(activeForThis != null && !activeForThis.isPaused);

    final currentElapsed = _currentSessionElapsed(activeForThis);
    final totalCounted = totalAsync.value ?? Duration.zero;
    final displayElapsed = totalCounted + currentElapsed;

    _maybeHourBoundaryHaptic(displayElapsed);

    return Scaffold(
      body: SafeArea(
        child: pursuitAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (pursuit) {
            if (pursuit == null) {
              return const Center(child: Text('Pursuit not found'));
            }
            return _Body(
              pursuit: pursuit,
              displayElapsed: displayElapsed,
              currentSessionElapsed: currentElapsed,
              active: activeForThis,
              streaks: streaksAsync.value ?? Streaks.empty,
              onTap: () => _onTap(activeForThis),
              onLongPress: () => _onLongPress(activeForThis),
            );
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.pursuit,
    required this.displayElapsed,
    required this.currentSessionElapsed,
    required this.active,
    required this.streaks,
    required this.onTap,
    required this.onLongPress,
  });

  final Pursuit pursuit;
  final Duration displayElapsed;
  final Duration currentSessionElapsed;
  final ActiveSession? active;
  final Streaks streaks;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String _formatHms(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Color(pursuit.accentColor);
    final status = active == null
        ? 'tap to start'
        : active!.isPaused
        ? 'paused — tap to resume, hold to stop'
        : 'running — tap to pause, hold to stop';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            pursuit.name,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              onLongPress: onLongPress,
              child: Semantics(
                button: true,
                child: RingWidget(
                  elapsed: displayElapsed,
                  targetHours: pursuit.targetHours,
                  accent: accent,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              if (streaks.currentDays > 0 || streaks.longestDays > 0)
                _StreakStrip(streaks: streaks),
              if (streaks.currentDays > 0 || streaks.longestDays > 0)
                const SizedBox(height: 12),
              if (active != null)
                Text(
                  _formatHms(currentSessionElapsed),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: theme.colorScheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                status,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakStrip extends StatelessWidget {
  const _StreakStrip({required this.streaks});
  final Streaks streaks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department_rounded,
          size: 18,
          color: streaks.currentDays > 0 ? scheme.primary : scheme.outline,
        ),
        const SizedBox(width: 6),
        Text(
          '${streaks.currentDays} day streak',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (streaks.longestDays > streaks.currentDays) ...[
          const SizedBox(width: 8),
          Text(
            '· longest ${streaks.longestDays}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
