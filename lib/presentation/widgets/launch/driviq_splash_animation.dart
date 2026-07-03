import 'dart:ui';

import 'package:flutter/material.dart';

class DriviqSplashAnimation {
  static const int totalMs = 4600;

  static const Color background = Color(0xFF05080C);
  static const Color cyan = Color(0xFF00E5FF);

  static double segment(double t, double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    final v = (t - start) / (end - start);
    return Curves.easeInOutCubic.transform(v);
  }
  static Path topStroke() {
    final p = Path();
    p.moveTo(0.03, 0.78);
    p.cubicTo(0.12, 0.48, 0.22, 0.44, 0.32, 0.50);
    p.cubicTo(0.42, 0.22, 0.54, 0.12, 0.66, 0.20);
    p.cubicTo(0.78, 0.28, 0.90, 0.44, 0.97, 0.58);
    return p;
  }

  static Path scaledBottom(Size size, Rect bounds) {
    final p = Path();
    p.moveTo(bounds.left, bounds.center.dy);
    p.lineTo(bounds.right, bounds.center.dy);
    return p;
  }

  static Path extractPartial(Path source, double progress) {
    final out = Path();
    for (final metric in source.computeMetrics()) {
      out.addPath(
        metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0)),
        Offset.zero,
      );
    }
    return out;
  }

}
