import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ten_k_hours/core/env/flavor.dart';
import 'package:ten_k_hours/core/theme/colors.dart';
import 'package:ten_k_hours/core/theme/theme.dart';
import 'package:ten_k_hours/core/theme/typography.dart';

final currentFlavor = Provider<Flavor>((ref) {
  throw UnimplementedError('currentFlavor must be overridden in bootstrap');
});

class TenKHoursApp extends ConsumerWidget {
  const TenKHoursApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(currentFlavor);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: flavor.appName,
          debugShowCheckedModeBanner: flavor == Flavor.dev,
          theme: buildTheme(lightDynamic ?? lightScheme()),
          darkTheme: buildTheme(darkDynamic ?? darkScheme()),
          home: const _PlaceholderHome(),
        );
      },
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('10,000', style: ringNumberStyle(scheme)),
              const SizedBox(height: 8),
              Text(
                'hours to mastery',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
