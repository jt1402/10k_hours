import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme interTextTheme(ColorScheme scheme) {
  final onSurface = scheme.onSurface;
  return TextTheme(
    displayLarge: _style(weight: FontWeight.w600, size: 57, color: onSurface),
    displayMedium: _style(weight: FontWeight.w600, size: 45, color: onSurface),
    displaySmall: _style(weight: FontWeight.w600, size: 36, color: onSurface),
    headlineLarge: _style(weight: FontWeight.w600, size: 32, color: onSurface),
    headlineMedium: _style(weight: FontWeight.w600, size: 28, color: onSurface),
    headlineSmall: _style(weight: FontWeight.w600, size: 24, color: onSurface),
    titleLarge: _style(weight: FontWeight.w500, size: 22, color: onSurface),
    titleMedium: _style(weight: FontWeight.w500, size: 16, color: onSurface),
    titleSmall: _style(weight: FontWeight.w500, size: 14, color: onSurface),
    bodyLarge: _style(weight: FontWeight.w400, size: 16, color: onSurface),
    bodyMedium: _style(weight: FontWeight.w400, size: 14, color: onSurface),
    bodySmall: _style(
      weight: FontWeight.w400,
      size: 12,
      color: scheme.onSurfaceVariant,
    ),
    labelLarge: _style(weight: FontWeight.w500, size: 14, color: onSurface),
    labelMedium: _style(weight: FontWeight.w500, size: 12, color: onSurface),
    labelSmall: _style(weight: FontWeight.w500, size: 11, color: onSurface),
  );
}

TextStyle _style({
  required FontWeight weight,
  required double size,
  required Color color,
}) {
  return GoogleFonts.geist(
    fontWeight: weight,
    fontSize: size,
    color: color,
    height: 1.2,
    letterSpacing: -0.2,
  );
}

TextStyle ringNumberStyle(ColorScheme scheme, {double size = 96}) {
  return GoogleFonts.geist(
    fontWeight: FontWeight.w600,
    fontSize: size,
    color: scheme.onSurface,
    height: 1,
    letterSpacing: -2,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
