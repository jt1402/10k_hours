import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ten_k_hours/core/env/flavor.dart';

final currentFlavor = Provider<Flavor>((ref) {
  throw UnimplementedError('currentFlavor must be overridden in bootstrap');
});

class TenKHoursApp extends ConsumerWidget {
  const TenKHoursApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(currentFlavor);
    return MaterialApp(
      title: flavor.appName,
      debugShowCheckedModeBanner: flavor == Flavor.dev,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14B8A6)),
      ),
      home: const _PlaceholderHome(),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '10k Hours',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
