import 'package:flutter/material.dart';

/// Vert émeraude, couleur de la marque VoyageCM.
const brandGreen = Color(0xFF047857);
const mtnYellow = Color(0xFFFFCC00);
const orangeMoney = Color(0xFFFF6600);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: brandGreen,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    appBarTheme: AppBarTheme(
      backgroundColor: brightness == Brightness.light
          ? brandGreen
          : scheme.surface,
      foregroundColor: brightness == Brightness.light
          ? Colors.white
          : scheme.onSurface,
      centerTitle: false,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    cardTheme: const CardThemeData(clipBehavior: Clip.antiAlias),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    ),
  );
}
