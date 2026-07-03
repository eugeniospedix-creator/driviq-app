import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dq_tokens.dart';
import 'dq_typography.dart';

abstract final class DriviqTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.dark(
      surface: DQ.graphite,
      onSurface: DQ.textPrimary,
      primary: DQ.cyan,
      onPrimary: DQ.graphite,
      secondary: DQ.emerald,
      error: DQ.coral,
      outline: DQ.line,
    );

    final textTheme = DqTypography.dark.apply(
      bodyColor: DQ.textPrimary,
      displayColor: DQ.textPrimary,
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DQ.voidBlack,
      colorScheme: scheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
