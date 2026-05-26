import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_providers.dart';
import 'package:ten_k_hours/features/pursuits/domain/pursuit.dart';
import 'package:ten_k_hours/features/sessions/data/session_providers.dart';
import 'package:ten_k_hours/features/sessions/domain/active_session.dart';

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
          // Disable when active session belongs to a different pursuit.
          final disabled = active != null && !isActiveOnThis;
          final accent = Color(p.accentColor);
          return ListTile(
            enabled: !disabled,
            leading: CircleAvatar(
              radius: 12,
              backgroundColor: accent,
            ),
            title: Text(p.name),
            subtitle: Text('${p.targetHours}-hour target'),
            trailing: isCurrent
                ? Icon(Icons.check_rounded, color: scheme.primary)
                : null,
            onTap: () {
              Navigator.of(context).pop();
              if (!isCurrent) context.replace('/pursuit/${p.id}');
            },
          );
        },
      ),
    );
  }
}
