import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ten_k_hours/core/env/flavor.dart';
import 'package:ten_k_hours/core/router/app_router.dart';
import 'package:ten_k_hours/core/theme/colors.dart';
import 'package:ten_k_hours/core/theme/theme.dart';

final currentFlavor = Provider<Flavor>((ref) {
  throw UnimplementedError('currentFlavor must be overridden in bootstrap');
});

class TenKHoursApp extends ConsumerWidget {
  const TenKHoursApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(currentFlavor);
    final router = ref.watch(goRouterProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          title: flavor.appName,
          debugShowCheckedModeBanner: flavor == Flavor.dev,
          theme: buildTheme(lightDynamic ?? lightScheme()),
          darkTheme: buildTheme(darkDynamic ?? darkScheme()),
          routerConfig: router,
        );
      },
    );
  }
}
