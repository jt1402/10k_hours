import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_providers.dart';
import 'package:ten_k_hours/features/pursuits/domain/pursuit.dart';
import 'package:ten_k_hours/features/pursuits/presentation/pursuit_switcher_sheet.dart';
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
  bool _liveActivityBootstrapped = false;
  String? _lastAdaptivePushed;
  DateTime? _lastAdaptivePushAt;

  void _ensureTicker(bool needTicker) {
    if (needTicker && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
          _maybePushAdaptiveDisplay();
        }
      });
    } else if (!needTicker && _ticker != null) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  // Push an adaptive display string to the Live Activity when elapsed crosses
  // 1h (auto-tick can no longer represent H:MM or Nh). Spaced 30s apart to
  // stay within ActivityKit's update budget. No-op while < 1h or paused.
  void _maybePushAdaptiveDisplay() {
    final active = ref.read(activeSessionProvider).value;
    if (active == null || active.isPaused) return;
    final elapsed = active.elapsedAt(DateTime.now().toUtc());
    final text = _adaptiveDisplay(elapsed);
    if (text == null) {
      _lastAdaptivePushed = null;
      _lastAdaptivePushAt = null;
      return;
    }
    final now = DateTime.now();
    final tooRecent =
        _lastAdaptivePushAt != null &&
        now.difference(_lastAdaptivePushAt!) < const Duration(seconds: 30);
    if (text == _lastAdaptivePushed && tooRecent) return;
    if (tooRecent) return;
    _lastAdaptivePushed = text;
    _lastAdaptivePushAt = now;
    unawaited(
      ref
          .read(liveActivityServiceProvider)
          .update(
            effectiveStartedAt: active.startedAt,
            isPaused: false,
            pausedAtFreezeSeconds: 0,
            displayText: text,
          ),
    );
  }

  static String? _adaptiveDisplay(Duration elapsed) {
    final h = elapsed.inHours;
    final m = elapsed.inMinutes % 60;
    if (h >= 100) return '${h}h';
    if (h >= 1) return '$h:${m.toString().padLeft(2, '0')}';
    return null;
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

  Future<void> _onTap(ActiveSession? active, Pursuit pursuit) async {
    final service = ref.read(sessionServiceProvider);
    final live = ref.read(liveActivityServiceProvider);
    if (active == null) {
      final started = await service.start(widget.pursuitId);
      unawaited(HapticFeedback.lightImpact());
      unawaited(
        live.start(
          pursuitName: pursuit.name,
          pursuitColorARGB: pursuit.accentColor,
          effectiveStartedAt: started.startedAt,
        ),
      );
    } else if (active.isPaused) {
      final resumed = await service.resume();
      unawaited(HapticFeedback.lightImpact());
      final now = DateTime.now().toUtc();
      final elapsed = resumed.elapsedAt(now);
      // Use start() rather than update() so the Activity is created if it
      // doesn't exist yet (e.g. on cold-start of a previously-paused session).
      final initialText = _adaptiveDisplay(elapsed);
      unawaited(
        live.start(
          pursuitName: pursuit.name,
          pursuitColorARGB: pursuit.accentColor,
          effectiveStartedAt: now.subtract(elapsed),
          displayText: initialText,
        ),
      );
      _lastAdaptivePushed = initialText;
      _lastAdaptivePushAt = initialText == null ? null : DateTime.now();
    } else {
      final paused = await service.pause();
      unawaited(HapticFeedback.lightImpact());
      final elapsed = paused.elapsedAt(DateTime.now().toUtc());
      unawaited(
        live.update(
          effectiveStartedAt: paused.startedAt,
          isPaused: true,
          pausedAtFreezeSeconds: elapsed.inSeconds,
        ),
      );
      _lastAdaptivePushed = null;
      _lastAdaptivePushAt = null;
    }
  }

  Future<void> _onLongPress(ActiveSession? active) async {
    if (active == null) return;
    final service = ref.read(sessionServiceProvider);
    final live = ref.read(liveActivityServiceProvider);
    final result = await service.stop();
    unawaited(HapticFeedback.mediumImpact());
    unawaited(live.end());
    _lastWholeHoursElapsed = -1;
    _lastAdaptivePushed = null;
    _lastAdaptivePushAt = null;
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

  // Cold-start bootstrap: if a session was already running (or paused) when
  // we cold-launched the app, kick off a Live Activity once we have pursuit
  // data. Runs at most once per session — resets when the active session
  // clears.
  void _maybeBootstrapLiveActivity(ActiveSession? active, Pursuit? pursuit) {
    if (active == null) {
      _liveActivityBootstrapped = false;
      return;
    }
    if (_liveActivityBootstrapped) return;
    if (pursuit == null) return;
    _liveActivityBootstrapped = true;
    final live = ref.read(liveActivityServiceProvider);
    final now = DateTime.now().toUtc();
    final elapsed = active.elapsedAt(now);
    final effectiveStart = now.subtract(elapsed);
    final initialText = active.isPaused ? null : _adaptiveDisplay(elapsed);
    unawaited(
      live.start(
        pursuitName: pursuit.name,
        pursuitColorARGB: pursuit.accentColor,
        effectiveStartedAt: effectiveStart,
        displayText: initialText,
      ),
    );
    _lastAdaptivePushed = initialText;
    _lastAdaptivePushAt = initialText == null ? null : DateTime.now();
    if (active.isPaused) {
      unawaited(
        live.update(
          effectiveStartedAt: effectiveStart,
          isPaused: true,
          pausedAtFreezeSeconds: elapsed.inSeconds,
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
    _maybeBootstrapLiveActivity(activeForThis, pursuitAsync.value);

    final currentElapsed = _currentSessionElapsed(activeForThis);
    final totalCounted = totalAsync.value ?? Duration.zero;
    final displayElapsed = totalCounted + currentElapsed;

    _maybeHourBoundaryHaptic(displayElapsed);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: pursuitAsync.when(
          data: (p) => p == null
              ? const Text('—')
              : _TitleButton(
                  name: p.name,
                  onTap: () => showPursuitSwitcher(
                    context,
                    currentPursuitId: widget.pursuitId,
                  ),
                ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Heatmap',
            onPressed: () =>
                context.push('/pursuit/${widget.pursuitId}/heatmap'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
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
              onTap: () => _onTap(activeForThis, pursuit),
              onLongPress: () => _onLongPress(activeForThis),
            );
          },
        ),
      ),
    );
  }
}

class _TitleButton extends StatelessWidget {
  const _TitleButton({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                style: theme.textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 22,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
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
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Semantics(
                    button: true,
                    child: RingWidget(
                      elapsed: displayElapsed,
                      targetMinutes: pursuit.targetMinutes,
                      accent: accent,
                      size: 340,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _StatsRow(
                    covered: displayElapsed,
                    targetMinutes: pursuit.targetMinutes,
                  ),
                ),
              ],
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
                  style: GoogleFonts.geist(
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.covered, required this.targetMinutes});

  final Duration covered;
  final int targetMinutes;

  Duration get _remaining {
    final r = Duration(minutes: targetMinutes) - covered;
    return r.isNegative ? Duration.zero : r;
  }

  String _formatHms(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final hs = h >= 1000 ? NumberFormat('#,##0').format(h) : h.toString();
    return '$hs:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: _StatCell(
            label: 'Covered',
            value: _formatHms(covered),
            scheme: scheme,
            alignment: CrossAxisAlignment.start,
          ),
        ),
        Container(
          width: 1,
          height: 32,
          color: scheme.outlineVariant,
        ),
        Expanded(
          child: _StatCell(
            label: 'Remaining',
            value: _formatHms(_remaining),
            scheme: scheme,
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.scheme,
    required this.alignment,
  });

  final String label;
  final String value;
  final ColorScheme scheme;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.geist(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            letterSpacing: 0.8,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.geist(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: scheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
