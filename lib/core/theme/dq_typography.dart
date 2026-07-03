import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dq_tokens.dart';

abstract final class DqTypography {
  static TextStyle _base({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      decoration: TextDecoration.none,
      decorationThickness: 0,
    );
  }

  static TextTheme get dark => TextTheme(
        displayLarge: _base(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.6,
          color: DQ.textPrimary,
          height: 1.05,
        ),
        headlineLarge: _base(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: DQ.textPrimary,
        ),
        headlineMedium: _base(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: DQ.textPrimary,
        ),
        headlineSmall: _base(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: DQ.textPrimary,
        ),
        titleLarge: _base(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: DQ.textPrimary,
        ),
        bodyLarge: _base(
          fontSize: 16,
          height: 1.45,
          color: DQ.textSecondary,
        ),
        bodyMedium: _base(
          fontSize: 14,
          height: 1.45,
          color: DQ.textMuted,
        ),
        labelLarge: _base(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: DQ.textMuted,
        ),
      );
}
