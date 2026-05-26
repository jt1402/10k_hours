import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_providers.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({required this.pursuitId, super.key});

  final int pursuitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pursuitAsync = ref.watch(pursuitByIdProvider(pursuitId));
    return Scaffold(
      body: SafeArea(
        child: pursuitAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (pursuit) {
            if (pursuit == null) {
              return const Center(child: Text('Pursuit not found'));
            }
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pursuit.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${pursuit.targetHours} hours',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text('ring + controls coming in next tasks'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
