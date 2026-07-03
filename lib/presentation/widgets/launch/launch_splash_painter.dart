import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import 'driviq_logo_geometry.dart';

class LaunchSplashPainter extends CustomPainter {
  LaunchSplashPainter({
    required this.drawProgress,
    required this.pulse,
    required this.settle,
    required this.leaderOpacity,
  });

  final double drawProgress;
  final double pulse;
  final double settle;
  final double leaderOpacity;

  static const _cyan = DQ.cyan;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = DQ.voidBlack,
    );

    final bounds = DriviqLogoGeometry.logoBounds(size);
    final bottom = DriviqLogoGeometry.scaledBottom(size, bounds);
    final top = DriviqLogoGeometry.scaledTop(size, bounds);
    final silhouette = DriviqLogoGeometry.scaledSilhouette(size, bounds);

    final ambient = Paint()
      ..shader = ui.Gradient.radial(
        bounds.center,
        bounds.width * 0.75,
        [
          _cyan.withValues(alpha: 0.035 + settle * 0.04),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(bounds.center, bounds.width * 0.7, ambient);

    final bottomT = DriviqLogoGeometry.splitProgress(drawProgress);
    final topT = DriviqLogoGeometry.topProgress(drawProgress);

    if (settle > 0.05) {
      canvas.drawPath(
        silhouette,
        Paint()
          ..shader = ui.Gradient.radial(
            bounds.center,
            bounds.width * 0.6,
            [
              const Color(0xFF1A2838).withValues(alpha: settle * 0.55),
              DQ.voidBlack.withValues(alpha: settle * 0.35),
            ],
          ),
      );
    }

    if (bottomT > 0) {
      _paintStroke(canvas, DriviqLogoGeometry.extractPartial(bottom, bottomT), width: 3.6, glow: 20);
    }

    if (topT > 0) {
      _paintStroke(canvas, DriviqLogoGeometry.extractPartial(top, topT), width: 3.2, glow: 18);
    }

    if (pulse > 0) {
      _paintHeartbeatPulse(canvas, size, pulse);
    }

    if (leaderOpacity > 0.02 && drawProgress < 0.98) {
      _paintLeader(canvas, size, bottom, top);
    }

    if (settle > 0.35) {
      canvas.drawPath(
        silhouette,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _cyan.withValues(alpha: settle * 0.12),
      );
    }
  }

  void _paintStroke(Canvas canvas, Path path, {required double width, required double glow}) {
    if (path.getBounds().isEmpty) return;

    canvas.drawPath(
      path,
      Paint()
        ..color = _cyan.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow),
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          path.getBounds().topLeft,
          path.getBounds().bottomRight,
          [_cyan, _cyan.withValues(alpha: 0.82)],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _paintLeader(Canvas canvas, Size size, Path bottom, Path top) {
    final pos = DriviqLogoGeometry.leaderPosition(drawProgress, size);
    final tangent = _tangentAt(drawProgress, size, bottom, top);
    final r = 3.5 + leaderOpacity * 1.5;

    canvas.drawCircle(
      pos,
      r + 12,
      Paint()
        ..color = _cyan.withValues(alpha: 0.22 * leaderOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          pos,
          r,
          [
            Colors.white.withValues(alpha: leaderOpacity),
            _cyan.withValues(alpha: 0.9 * leaderOpacity),
          ],
        ),
    );

    if (tangent != null) {
      final tail = pos - tangent * 18;
      canvas.drawLine(
        tail,
        pos,
        Paint()
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            tail,
            pos,
            [Colors.transparent, _cyan.withValues(alpha: 0.5 * leaderOpacity)],
          ),
      );
    }
  }

  Offset? _tangentAt(double t, Size size, Path bottom, Path top) {
    final onBottom = t <= DriviqLogoGeometry.drawBottomWeight;
    final path = onBottom ? bottom : top;
    final progress = onBottom ? DriviqLogoGeometry.splitProgress(t) : DriviqLogoGeometry.topProgress(t);
    for (final metric in path.computeMetrics()) {
      final offset = metric.length * progress.clamp(0, 1);
      final tan = metric.getTangentForOffset(offset);
      return tan?.vector;
    }
    return null;
  }

  void _paintHeartbeatPulse(Canvas canvas, Size size, double pulse) {
    final center = DriviqLogoGeometry.heartbeatCenter(size);
    final alpha = (1 - pulse) * 0.5;

    canvas.drawCircle(
      center,
      32 + pulse * 12,
      Paint()
        ..color = _cyan.withValues(alpha: alpha * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    canvas.drawCircle(
      center,
      6,
      Paint()..color = _cyan.withValues(alpha: alpha * 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant LaunchSplashPainter old) =>
      old.drawProgress != drawProgress ||
      old.pulse != pulse ||
      old.settle != settle ||
      old.leaderOpacity != leaderOpacity;
}
