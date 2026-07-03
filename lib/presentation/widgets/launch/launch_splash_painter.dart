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
    required this.backgroundPulse,
  });

  /// 0–1 combined bottom + top stroke draw.
  final double drawProgress;

  /// Heartbeat pulse glow 0–1.
  final double pulse;

  /// Logo settle / lock-in 0–1.
  final double settle;

  /// Leading car-light intensity.
  final double leaderOpacity;

  /// Ambient background breathe.
  final double backgroundPulse;

  static const _cyan = DQ.cyan;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);

    final bounds = DriviqLogoGeometry.logoBounds(size);
    final bottom = DriviqLogoGeometry.scaledBottom(size, bounds);
    final top = DriviqLogoGeometry.scaledTop(size, bounds);

    final bottomT = DriviqLogoGeometry.splitProgress(drawProgress);
    final topT = DriviqLogoGeometry.topProgress(drawProgress);

    if (bottomT > 0) {
      _paintStroke(
        canvas,
        DriviqLogoGeometry.extractPartial(bottom, bottomT),
        width: 3.8,
        glow: 18,
        alpha: 0.85 + settle * 0.15,
      );
    }

    if (topT > 0) {
      _paintStroke(
        canvas,
        DriviqLogoGeometry.extractPartial(top, topT),
        width: 3.4,
        glow: 16,
        alpha: 0.85 + settle * 0.15,
      );
    }

    if (pulse > 0) {
      _paintHeartbeatPulse(canvas, size, pulse);
    }

    if (drawProgress > 0 && drawProgress < 1.0) {
      _paintLeader(canvas, size);
    }

    if (settle > 0) {
      _paintSettledGlow(canvas, bounds, settle);
    }
  }

  void _paintBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = DQ.voidBlack,
    );

    final cx = size.width * 0.5;
    final cy = size.height * 0.44;
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.55,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy - 20),
          size.width * 0.5,
          [
            _cyan.withValues(alpha: 0.04 + backgroundPulse * 0.03),
            Colors.transparent,
          ],
        ),
    );
  }

  void _paintStroke(
    Canvas canvas,
    Path path, {
    required double width,
    required double glow,
    required double alpha,
  }) {
    if (path.getBounds().isEmpty) return;

    canvas.drawPath(
      path,
      Paint()
        ..color = _cyan.withValues(alpha: alpha * 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 6
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
          [
            _cyan.withValues(alpha: alpha),
            _cyan.withValues(alpha: alpha * 0.75),
          ],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _paintLeader(Canvas canvas, Size size) {
    final pos = DriviqLogoGeometry.leaderPosition(drawProgress, size);
    final r = 4.5 + leaderOpacity * 2;

    canvas.drawCircle(
      pos,
      r + 14,
      Paint()
        ..color = _cyan.withValues(alpha: 0.18 * leaderOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          pos,
          r,
          [
            Colors.white.withValues(alpha: 0.95 * leaderOpacity),
            _cyan.withValues(alpha: 0.85 * leaderOpacity),
          ],
        ),
    );
  }

  void _paintHeartbeatPulse(Canvas canvas, Size size, double pulse) {
    final center = DriviqLogoGeometry.heartbeatCenter(size);
    final expand = 1 + pulse * 0.8;
    final alpha = (1 - pulse) * 0.45;

    canvas.drawCircle(
      center,
      28 * expand,
      Paint()
        ..color = _cyan.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    canvas.drawCircle(
      center,
      8 + pulse * 6,
      Paint()..color = _cyan.withValues(alpha: (1 - pulse) * 0.6),
    );
  }

  void _paintSettledGlow(Canvas canvas, Rect bounds, double settle) {
    final alpha = settle * 0.12;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.inflate(24), const Radius.circular(32)),
      Paint()
        ..shader = ui.Gradient.radial(
          bounds.center,
          bounds.width * 0.55,
          [
            _cyan.withValues(alpha: alpha),
            Colors.transparent,
          ],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant LaunchSplashPainter old) =>
      old.drawProgress != drawProgress ||
      old.pulse != pulse ||
      old.settle != settle ||
      old.leaderOpacity != leaderOpacity ||
      old.backgroundPulse != backgroundPulse;
}
