import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ten_k_hours/app.dart';
import 'package:ten_k_hours/core/env/flavor.dart';

Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        currentFlavor.overrideWithValue(flavor),
      ],
      child: const TenKHoursApp(),
    ),
  );
}
