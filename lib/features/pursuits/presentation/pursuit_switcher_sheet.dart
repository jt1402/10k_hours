import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_providers.dart';
import 'package:ten_k_hours/features/pursuits/domain/pursuit.dart';
import 'package:ten_k_hours/features/sessions/data/session_providers.dart';
import 'package:ten_k_hours/features/sessions/domain/active_session.dart';

String _formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0) return '${h}h ${m}m';
  if (m > 0) return '${m}m';
  return 'less than a minute';
}

String _targetLabel(int targetMinutes) {
  if (targetMinutes >= 60 && targetMinutes % 60 == 0) {
    return '${targetMinutes ~/ 60}-hour target';
  }
  if (targetMinutes < 60) return '$targetMinutes-minute target';
  final h = targetMinutes ~/ 60;
  final m = targetMinutes % 60;
  return '${h}h ${m}m target';
}

Future<void> showPursuitSwitcher(
  BuildContext context, {
  required int currentPursuitId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _PursuitSwitcherSheet(currentPursuitId: currentPursuitId),
  );
}

class _PursuitSwitcherSheet extends ConsumerWidget {
  const _PursuitSwitcherSheet({required this.currentPursuitId});
  final int currentPursuitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pursuitsAsync = ref.watch(pursuitListProvider);
    final activeAsync = ref.watch(activeSessionProvider);
    final active = activeAsync.value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            if (active != null) _RunningBanner(active: active),
            pursuitsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: $e'),
              ),
              data: (list) => _PursuitList(
                pursuits: list,
                currentPursuitId: currentPursuitId,
                active: active,
              ),
            ),
            const Divider(height: 8),
            ListTile(
              leading: const Icon(Icons.add_rounded),
              title: const Text('New pursuit'),
              onTap: () {
                Navigator.of(context).pop();
                unawaited(context.push('/create'));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Text(
        'Switch pursuit',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _RunningBanner extends StatelessWidget {
  const _RunningBanner({required this.active});
  final ActiveSession active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Stop the current session before switching.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PursuitList extends ConsumerWidget {
  const _PursuitList({
    required this.pursuits,
    required this.currentPursuitId,
    required this.active,
  });

  final List<Pursuit> pursuits;
  final int currentPursuitId;
  final ActiveSession? active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: pursuits.length,
        itemBuilder: (context, i) {
          final p = pursuits[i];
          final isCurrent = p.id == currentPursuitId;
          final isActiveOnThis = active?.pursuitId == p.id;
          // Disable when a session is active on a different pursuit.
          final switchDisabled = active != null && !isActiveOnThis;
          final accent = Color(p.accentColor);
          return Dismissible(
            key: ValueKey('pursuit-${p.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: scheme.errorContainer,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    color: scheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (_) =>
                _confirmDelete(context, ref, p, isActiveOnThis),
            onDismissed: (_) => _onDeleted(context, ref, p, isCurrent),
            child: ListTile(
              enabled: !switchDisabled,
              leading: CircleAvatar(
                radius: 12,
                backgroundColor: accent,
              ),
              title: Text(p.name),
              subtitle: Text(_targetLabel(p.targetMinutes)),
              trailing: isCurrent
                  ? Icon(Icons.check_rounded, color: scheme.primary)
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                if (!isCurrent) context.replace('/pursuit/${p.id}');
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Pursuit pursuit,
    bool isActiveOnThis,
  ) async {
    if (isActiveOnThis) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stop the current session before deleting.'),
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final count = await sessionRepo.countFor(pursuit.id);
    final total = await sessionRepo.totalCountedDurationFor(pursuit.id);
    if (!context.mounted) return false;
    return await showDialog<bool>(
          context: context,
          builder: (dialogCtx) {
            final theme = Theme.of(dialogCtx);
            return AlertDialog(
              title: Text('Delete ${pursuit.name}?'),
              content: Text(
                count == 0
                    ? 'This pursuit has no recorded sessions. '
                          'This cannot be undone.'
                    : '$count session${count == 1 ? '' : 's'} '
                          '(${_formatDuration(total)} of practice) '
                          'will be permanently deleted. This cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _onDeleted(
    BuildContext context,
    WidgetRef ref,
    Pursuit pursuit,
    bool wasCurrent,
  ) async {
    await ref.read(pursuitRepositoryProvider).delete(pursuit.id);
    if (!context.mounted) return;
    if (wasCurrent) {
      // Pop sheet, then route to root so HomeScreen picks the next pursuit
      // (or shows the empty state).
      Navigator.of(context).pop();
      context.go('/');
    }
  }
}
