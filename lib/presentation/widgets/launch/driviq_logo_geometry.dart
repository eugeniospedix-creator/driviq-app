import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Vector geometry matching the approved Driviq app icon — roof arc + heartbeat body line.
abstract final class DriviqLogoGeometry {
  static const drawBottomWeight = 0.58;
  static const drawTopWeight = 0.42;

  /// Bottom body stroke with integrated EKG pulse (normalized 0–1 space).
  static Path bottomStroke() {
    return Path()
      ..moveTo(0.10, 0.60)
      ..lineTo(0.36, 0.60)
      ..lineTo(0.40, 0.47)
      ..lineTo(0.44, 0.72)
      ..lineTo(0.48, 0.50)
      ..lineTo(0.52, 0.60)
      ..lineTo(0.86, 0.60)
      ..quadraticBezierTo(0.92, 0.66, 0.88, 0.60);
  }

  /// Upper roofline arc (normalized 0–1 space).
  static Path topStroke() {
    return Path()
      ..moveTo(0.14, 0.54)
      ..cubicTo(0.24, 0.26, 0.52, 0.20, 0.72, 0.28)
      ..cubicTo(0.86, 0.34, 0.90, 0.46, 0.84, 0.52);
  }

  static Path scaledBottom(Size size, Rect bounds) => _transform(bottomStroke(), bounds);

  static Path scaledTop(Size size, Rect bounds) => _transform(topStroke(), bounds);

  static Path _transform(Path normalized, Rect bounds) {
    final m = Matrix4.identity()
      ..translateByDouble(bounds.left, bounds.top, 0, 1)
      ..scaleByDouble(bounds.width, bounds.height, 1, 1);
    return normalized.transform(m.storage);
  }

  static Rect logoBounds(Size size) {
    final side = math.min(size.width, size.height) * 0.52;
    return Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.46), width: side * 1.35, height: side);
  }

  /// Overall draw progress 0–1 across bottom then top strokes.
  static double splitProgress(double t) => (t / drawBottomWeight).clamp(0.0, 1.0);

  static double topProgress(double t) {
    if (t <= drawBottomWeight) return 0;
    return ((t - drawBottomWeight) / drawTopWeight).clamp(0.0, 1.0);
  }

  static Offset leaderPosition(double t, Size size) {
    final bounds = logoBounds(size);
    final bottom = scaledBottom(size, bounds);
    final top = scaledTop(size, bounds);

    if (t <= drawBottomWeight) {
      final p = splitProgress(t);
      return _pointOnPath(bottom, p);
    }
    final p = topProgress(t);
    return _pointOnPath(top, p);
  }

  static Offset _pointOnPath(Path path, double progress) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final len = metric.length * progress.clamp(0, 1);
      return metric.getTangentForOffset(len)?.position ?? Offset.zero;
    }
    return Offset.zero;
  }

  static Path extractPartial(Path path, double progress) {
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0) return Path();
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      return metric.extractPath(0, metric.length * p);
    }
    return Path();
  }

  /// Heartbeat segment center for pulse glow (normalized → scaled).
  static Offset heartbeatCenter(Size size) {
    final bounds = logoBounds(size);
    return Offset(bounds.left + bounds.width * 0.46, bounds.top + bounds.height * 0.58);
  }
}
