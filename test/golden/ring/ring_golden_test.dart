import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ten_k_hours/core/constants.dart';
import 'package:ten_k_hours/core/theme/colors.dart';
import 'package:ten_k_hours/core/theme/theme.dart';
import 'package:ten_k_hours/features/sessions/presentation/ring/ring_widget.dart';

Widget _harness(Widget child) {
  return MaterialApp(
    theme: buildTheme(lightScheme()),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('RingWidget goldens', () {
    testWidgets('0%', (tester) async {
      await tester.pumpWidget(_harness(
        const RingWidget(
          elapsed: Duration.zero,
          targetHours: kDefaultTargetHours,
          accent: kDefaultAccentColor,
        ),
      ));
      await expectLater(
        find.byType(RingWidget),
        matchesGoldenFile('goldens/ring_0pct.png'),
      );
    });

    testWidgets('47%', (tester) async {
      await tester.pumpWidget(_harness(
        const RingWidget(
          elapsed: Duration(hours: 4700),
          targetHours: kDefaultTargetHours,
          accent: kDefaultAccentColor,
        ),
      ));
      await expectLater(
        find.byType(RingWidget),
        matchesGoldenFile('goldens/ring_47pct.png'),
      );
    });

    testWidgets('100%', (tester) async {
      await tester.pumpWidget(_harness(
        const RingWidget(
          elapsed: Duration(hours: 10000),
          targetHours: kDefaultTargetHours,
          accent: kDefaultAccentColor,
        ),
      ));
      await expectLater(
        find.byType(RingWidget),
        matchesGoldenFile('goldens/ring_100pct.png'),
      );
    });
  });
}
