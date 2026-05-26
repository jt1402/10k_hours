import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_providers.dart';
import 'package:ten_k_hours/features/sessions/presentation/timer_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pursuitsAsync = ref.watch(pursuitListProvider);
    return pursuitsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (list) {
        if (list.isEmpty) return const _EmptyState();
        return TimerScreen(pursuitId: list.first.id);
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('10k Hours', style: theme.textTheme.displaySmall),
                const SizedBox(height: 16),
                Text(
                  'Pick a pursuit. Run the timer. Watch the ring count down.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.go('/create'),
                  child: const Text('Create your first pursuit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
