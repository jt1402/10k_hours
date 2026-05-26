import 'package:flutter/material.dart';
import 'package:ten_k_hours/core/theme/colors.dart';
import 'package:ten_k_hours/core/theme/typography.dart';

ThemeData buildTheme(ColorScheme scheme) {
  final textTheme = interTextTheme(scheme);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    fontFamily: 'Inter',
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}

ThemeData buildLightTheme([Color? seed]) =>
    buildTheme(lightScheme(seed ?? seedColor));

ThemeData buildDarkTheme([Color? seed]) =>
    buildTheme(darkScheme(seed ?? seedColor));
