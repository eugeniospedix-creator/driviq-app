import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import 'driviq_splash_animation.dart';

/// Cyan glow + heartbeat trace drawn over the approved static icon — overlay only.
class LaunchSplashOverlayPainter extends CustomPainter {
  LaunchSplashOverlayPainter({
    required this.glow,
    required this.lineProgress,
    required this.pulse,
  });

  final double glow;
  final double lineProgress;
  final double pulse;

  static const _cyan = DQ.cyan;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final bottom = DriviqSplashAnimation.scaledBottom(size, bounds);

    if (glow > 0) {
      canvas.drawCircle(
        bounds.center,
        bounds.shortestSide * 0.62,
        Paint()
          ..shader = ui.Gradient.radial(
            bounds.center,
            bounds.shortestSide * 0.62,
            [
              _cyan.withValues(alpha: 0.14 * glow),
              _cyan.withValues(alpha: 0.04 * glow),
              Colors.transparent,
            ],
            [0.0, 0.45, 1.0],
          ),
      );
    }

    final lineT = lineProgress.clamp(0.0, 1.0);
    if (lineT > 0) {
      final partial = DriviqSplashAnimation.extractPartial(bottom, lineT);
      _paintStroke(canvas, partial, width: 2.4, glow: 10, alpha: 0.75);
    }

    if (pulse > 0) {
      final center = Offset(bounds.width * 0.46, bounds.height * 0.58);
      final alpha = (1 - pulse) * 0.55;
      canvas.drawCircle(
        center,
        18 + pulse * 10,
        Paint()
          ..color = _cyan.withValues(alpha: alpha * 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
      canvas.drawCircle(
        center,
        3.5,
        Paint()..color = _cyan.withValues(alpha: alpha * 0.9),
      );
    }
  }

  void _paintStroke(Canvas canvas, Path path, {required double width, required double glow, required double alpha}) {
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
        ..color = _cyan.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant LaunchSplashOverlayPainter old) =>
      old.glow != glow || old.lineProgress != lineProgress || old.pulse != pulse;
}
