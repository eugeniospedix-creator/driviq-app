import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dq_tokens.dart';

abstract final class DqTypography {
  static TextTheme get dark => TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.6,
          color: DQ.textPrimary,
          height: 1.05,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: DQ.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: DQ.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: DQ.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          height: 1.45,
          color: DQ.textSecondary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          height: 1.45,
          color: DQ.textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: DQ.textMuted,
        ),
      );
}
