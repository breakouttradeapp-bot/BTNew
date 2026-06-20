import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const seed = Color(0xFF00C853);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  ).copyWith(
    primary: seed,
    secondary: const Color(0xFF1565C0),
    surface: const Color(0xFFF8FFF9),
    background: Colors.white,
    error: const Color(0xFFD32F2F),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    primaryColor: seed,
    fontFamily: 'Nunito',
    cardTheme: CardTheme(
      elevation: 3,
      shadowColor: Colors.green.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1A1A2E),
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1A2E),
      ),
    ),
  );
}
