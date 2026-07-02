import 'package:flutter/material.dart';

/// Driviq design tokens — dark-first premium palette.
abstract final class DQ {
  static const voidBlack = Color(0xFF05080C);
  static const graphite = Color(0xFF0B1015);
  static const graphite2 = Color(0xFF111A22);
  static const graphite3 = Color(0xFF18222C);
  static const snow = Color(0xFFF8FAFC);
  static const ice = Color(0xFFEEF5F7);
  static const pearl = Color(0xFFFFFFFF);
  static const cyan = Color(0xFF22D3EE);
  static const cyanDim = Color(0xFF0E7490);
  static const cyanSoft = Color(0x331ED4E8);
  static const emerald = Color(0xFF1ED68A);
  static const emeraldSoft = Color(0x331ED68A);
  static const amber = Color(0xFFFFB84D);
  static const amberSoft = Color(0x33FFB84D);
  static const coral = Color(0xFFFF5B5B);
  static const coralSoft = Color(0x33FF5B5B);
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);
  static const line = Color(0xFF1E293B);
  static const glass = Color(0xCC111A22);
  static const glassBorder = Color(0x33FFFFFF);

  static const radiusSm = 16.0;
  static const radiusMd = 24.0;
  static const radiusLg = 34.0;
  static const radiusXl = 40.0;

  static const spaceXs = 8.0;
  static const spaceSm = 12.0;
  static const spaceMd = 18.0;
  static const spaceLg = 24.0;
  static const spaceXl = 32.0;

  static Color healthColor(int score) {
    if (score >= 90) return emerald;
    if (score >= 75) return cyan;
    if (score >= 60) return amber;
    return coral;
  }
}
