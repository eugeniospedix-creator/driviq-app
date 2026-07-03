import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'driviq_splash_animation.dart';

class DriviqSplashPainter extends CustomPainter {
  DriviqSplashPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = DriviqSplashAnimation.background,
    );

    final center = Offset(size.width / 2, size.height / 2);
    final logoWidth = size.width * 0.74;
    final logoHeight = logoWidth * 0.24;
    final x = center.dx - logoWidth / 2;
    final y = center.dy - logoHeight * 0.45;

    final carPath = _premiumCarPath(x, y, logoWidth * 0.56, logoHeight);
    final wordStartX = x + logoWidth * 0.58;
    final wordY = y + logoHeight * 0.23;

    final carProgress = DriviqSplashAnimation.segment(t, 0.0, 0.52);
    final textProgress = DriviqSplashAnimation.segment(t, 0.60, 0.88);
    final finalGlow = DriviqSplashAnimation.segment(t, 0.86, 0.94);
    final fadeOut = DriviqSplashAnimation.segment(t, 0.94, 1.0);
    final opacity = (1 - fadeOut).clamp(0.0, 1.0);

    _drawAnimatedPath(canvas, carPath, carProgress, opacity, finalGlow);

    if (textProgress > 0) {
      _drawRevealedText(
        canvas,
        'DRIVIQ',
        Offset(wordStartX, wordY),
        logoHeight * 0.50,
        textProgress,
        opacity,
        finalGlow,
      );
    }

    final activePath = carProgress < 1 ? carPath : null;
    if (activePath != null) {
      final dot = _pointAt(activePath, carProgress);
      if (dot != null) {
        canvas.drawCircle(
          dot,
          3.4,
          Paint()
            ..color = DriviqSplashAnimation.cyan.withOpacity(opacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
    }
  }

  Path _premiumCarPath(double x, double y, double w, double h) {
    final p = Path();

    // ECG ONLY — no car silhouette.
    final cy = y + h * 0.62;

    p.moveTo(x + w * 0.02, cy);
    p.lineTo(x + w * 0.20, cy);
    p.lineTo(x + w * 0.25, y + h * 0.44);
    p.lineTo(x + w * 0.30, y + h * 0.80);
    p.lineTo(x + w * 0.36, y + h * 0.18);
    p.lineTo(x + w * 0.44, y + h * 0.92);
    p.lineTo(x + w * 0.52, cy);
    p.lineTo(x + w * 0.67, cy);
    p.lineTo(x + w * 0.71, y + h * 0.48);
    p.lineTo(x + w * 0.76, y + h * 0.72);
    p.lineTo(x + w * 0.83, cy);
    p.lineTo(x + w * 1.02, cy);

    return p;
  }

  void _drawAnimatedPath(Canvas canvas, Path path, double progress, double opacity, double finalGlow) {
    final drawn = _extractPath(path, progress);
    final glowAlpha = (0.20 + finalGlow * 0.16) * opacity;

    canvas.drawPath(
      drawn,
      Paint()
        ..color = DriviqSplashAnimation.cyan.withOpacity(glowAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawPath(
      drawn,
      Paint()
        ..color = DriviqSplashAnimation.cyan.withOpacity(0.40 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawPath(
      drawn,
      Paint()
        ..color = DriviqSplashAnimation.cyan.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawRevealedText(
    Canvas canvas,
    String text,
    Offset origin,
    double fontSize,
    double progress,
    double opacity,
    double finalGlow,
  ) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: DriviqSplashAnimation.cyan.withOpacity(opacity),
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: fontSize * 0.12,
        height: 1,
      ),
    );

    final painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final revealWidth = painter.width * progress.clamp(0.0, 1.0);
    final rect = Rect.fromLTWH(origin.dx, origin.dy, revealWidth, painter.height + 8);

    canvas.save();
    canvas.clipRect(rect);

    // Glow text pass.
    final glowSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: DriviqSplashAnimation.cyan.withOpacity((0.20 + finalGlow * 0.18) * opacity),
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: fontSize * 0.12,
        height: 1,
        shadows: const [
          Shadow(
            blurRadius: 22,
            color: DriviqSplashAnimation.cyan,
          ),
        ],
      ),
    );
    TextPainter(text: glowSpan, textDirection: TextDirection.ltr, maxLines: 1)
      ..layout()
      ..paint(canvas, origin);

    painter.paint(canvas, origin);
    canvas.restore();

    // Connecting write-on line from car to text.
    if (progress < 1) {
      final tipX = origin.dx + revealWidth;
      final tipY = origin.dy + painter.height * 0.58;
      canvas.drawCircle(
        Offset(tipX, tipY),
        2.8,
        Paint()
          ..color = DriviqSplashAnimation.cyan.withOpacity(opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
  }

  Path _extractPath(Path source, double progress) {
    final out = Path();
    for (final metric in source.computeMetrics()) {
      final length = metric.length * progress.clamp(0.0, 1.0);
      out.addPath(metric.extractPath(0, length), Offset.zero);
    }
    return out;
  }

  Offset? _pointAt(Path source, double progress) {
    final metrics = source.computeMetrics().toList();
    if (metrics.isEmpty) return null;

    var target = 0.0;
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    final wanted = total * progress.clamp(0.0, 1.0);

    for (final metric in metrics) {
      if (target + metric.length >= wanted) {
        return metric.getTangentForOffset(wanted - target)?.position;
      }
      target += metric.length;
    }
    return metrics.last.getTangentForOffset(metrics.last.length)?.position;
  }

  @override
  bool shouldRepaint(covariant DriviqSplashPainter oldDelegate) => oldDelegate.t != t;
}
