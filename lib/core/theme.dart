import 'package:flutter/material.dart';

class DQ {
  static const graphite = Color(0xFF0B1015);
  static const graphite2 = Color(0xFF111A22);
  static const snow = Color(0xFFF8FAFC);
  static const ice = Color(0xFFEEF5F7);
  static const pearl = Color(0xFFFFFFFF);
  static const cyan = Color(0xFF22D3EE);
  static const cyanSoft = Color(0xFFE7FBFF);
  static const emerald = Color(0xFF1ED68A);
  static const emeraldSoft = Color(0xFFE8FFF5);
  static const amber = Color(0xFFFFB84D);
  static const coral = Color(0xFFFF5B5B);
  static const text = Color(0xFF0B1015);
  static const muted = Color(0xFF6B7680);
  static const line = Color(0xFFE2E8F0);
}

class DriviqTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: DQ.snow,
        colorScheme: ColorScheme.fromSeed(seedColor: DQ.cyan),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -1.8, color: DQ.text),
          headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1.0, color: DQ.text),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: DQ.text),
          bodyLarge: TextStyle(fontSize: 17, height: 1.35, color: DQ.text),
          bodyMedium: TextStyle(fontSize: 15, height: 1.35, color: DQ.muted),
          labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: .3),
        ),
      );
}
