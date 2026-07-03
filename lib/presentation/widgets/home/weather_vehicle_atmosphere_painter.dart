import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/enums/driviq_weather_mood.dart';

enum WeatherAtmosphereLayer { behindVehicle, inFrontOfVehicle }

/// CustomPainter for Home hero weather overlays — lightweight, no external assets.
class WeatherVehicleAtmospherePainter extends CustomPainter {
  WeatherVehicleAtmospherePainter({
    required this.mood,
    required this.layer,
    required this.phase,
    required this.accent,
    required this.particleScale,
  });

  final DriviqWeatherMood mood;
  final WeatherAtmosphereLayer layer;
  final double phase;
  final Color accent;
  final double particleScale;

  static const _warmSun = Color(0xFFFFC27A);
  static const _coolSky = Color(0xFF8BA4BC);
  static const _nightBlue = Color(0xFF0A1420);

  Rect _carBounds(Size size) =>
      Rect.fromLTWH(size.width * 0.07, size.height * 0.16, size.width * 0.86, size.height * 0.50);

  Rect _floorBounds(Size size) {
    final car = _carBounds(size);
    return Rect.fromCenter(
      center: Offset(car.center.dx, car.bottom + size.height * 0.04),
      width: car.width * 0.78,
      height: size.height * 0.05,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mood == DriviqWeatherMood.unknown) {
      if (layer == WeatherAtmosphereLayer.behindVehicle) {
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.radial(
              Offset(size.width * 0.5, size.height * 0.35),
              size.width * 0.7,
              [DQ.cyan.withValues(alpha: 0.05), Colors.transparent],
            ),
        );
      }
      return;
    }

    if (layer == WeatherAtmosphereLayer.behindVehicle) {
      _paintAmbient(canvas, size);
    } else {
      _paintForeground(canvas, size);
    }
  }

  void _paintAmbient(Canvas canvas, Size size) {
    switch (mood) {
      case DriviqWeatherMood.clearDay:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.radial(
              Offset(size.width * 0.24, size.height * 0.10),
              size.width * 0.78,
              [_warmSun.withValues(alpha: 0.20), _warmSun.withValues(alpha: 0.06), Colors.transparent],
              [0.0, 0.38, 1.0],
            ),
        );
      case DriviqWeatherMood.clearNight:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, 0),
              Offset(0, size.height),
              [_nightBlue.withValues(alpha: 0.62), DQ.voidBlack.withValues(alpha: 0.30), Colors.transparent],
              const [0.0, 0.55, 1.0],
            ),
        );
      case DriviqWeatherMood.cloudy:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, 0),
              Offset(size.width, size.height * 0.8),
              [_coolSky.withValues(alpha: 0.18), const Color(0xFF1A2430).withValues(alpha: 0.24), Colors.transparent],
              const [0.0, 0.6, 1.0],
            ),
        );
      case DriviqWeatherMood.rain:
      case DriviqWeatherMood.storm:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.linear(
              const Offset(0, 0),
              Offset(0, size.height),
              [
                const Color(0xFF101820).withValues(alpha: mood == DriviqWeatherMood.storm ? 0.48 : 0.36),
                const Color(0xFF0A1018).withValues(alpha: 0.20),
                Colors.transparent,
              ],
              const [0.0, 0.5, 1.0],
            ),
        );
      case DriviqWeatherMood.snow:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, 0),
              Offset(0, size.height),
              [const Color(0xFFDCE6F0).withValues(alpha: 0.12), const Color(0xFF1A2430).withValues(alpha: 0.14)],
            ),
        );
      case DriviqWeatherMood.fog:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, size.height * 0.06),
              Offset(0, size.height * 0.74),
              [Colors.white.withValues(alpha: 0.12), Colors.white.withValues(alpha: 0.20), Colors.white.withValues(alpha: 0.07)],
              const [0.0, 0.5, 1.0],
            ),
        );
      case DriviqWeatherMood.unknown:
        break;
    }
  }

  void _paintForeground(Canvas canvas, Size size) {
    final car = _carBounds(size);

    switch (mood) {
      case DriviqWeatherMood.clearDay:
        _paintBodyGloss(canvas, car, Colors.white.withValues(alpha: 0.16), warm: true);
      case DriviqWeatherMood.clearNight:
        _paintHeadlights(canvas, car);
        _paintBodyGloss(canvas, car, accent.withValues(alpha: 0.12), warm: false);
        _paintWetFloor(canvas, size, tint: accent.withValues(alpha: 0.16));
      case DriviqWeatherMood.cloudy:
        _paintBodyGloss(canvas, car, _coolSky.withValues(alpha: 0.11), warm: false);
      case DriviqWeatherMood.rain:
        _paintRain(canvas, size, intensity: 1.0);
        _paintWetFloor(canvas, size);
        _paintBodyGloss(canvas, car, Colors.white.withValues(alpha: 0.09), warm: false);
      case DriviqWeatherMood.storm:
        _paintRain(canvas, size, intensity: 1.65);
        _paintWetFloor(canvas, size, tint: Colors.white.withValues(alpha: 0.14));
        _paintStormFlash(canvas, size);
        _paintBodyGloss(canvas, car, Colors.white.withValues(alpha: 0.07), warm: false);
      case DriviqWeatherMood.snow:
        _paintSnowfall(canvas, size);
        _paintSnowCap(canvas, car);
        _paintBodyGloss(canvas, car, Colors.white.withValues(alpha: 0.13), warm: false);
      case DriviqWeatherMood.fog:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.radial(
              Offset(size.width * 0.5, size.height * 0.42),
              size.width * 0.75,
              [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.18), Colors.white.withValues(alpha: 0.05)],
              const [0.0, 0.5, 1.0],
            ),
        );
      case DriviqWeatherMood.unknown:
        break;
    }
  }

  void _paintBodyGloss(Canvas canvas, Rect car, Color tint, {required bool warm}) {
    final highlight = Rect.fromLTWH(
      car.left + car.width * 0.12,
      car.top + car.height * 0.18,
      car.width * 0.62,
      car.height * 0.22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlight, const Radius.circular(28)),
      Paint()
        ..shader = ui.Gradient.linear(highlight.topLeft, highlight.bottomRight, [tint, Colors.transparent]),
    );
    if (warm) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(car.left + car.width * 0.08, car.top + car.height * 0.42, car.width * 0.35, car.height * 0.12),
          const Radius.circular(20),
        ),
        Paint()..color = _warmSun.withValues(alpha: 0.10),
      );
    }
  }

  void _paintWetFloor(Canvas canvas, Size size, {Color? tint}) {
    final floor = _floorBounds(size);
    final shimmer = math.sin(phase * math.pi * 2) * 0.05;
    canvas.drawOval(
      floor.inflate(size.height * 0.01),
      Paint()
        ..shader = ui.Gradient.radial(
          floor.center,
          floor.width * 0.5,
          [(tint ?? Colors.white.withValues(alpha: 0.18 + shimmer)), Colors.transparent],
        ),
    );
  }

  void _paintRain(Canvas canvas, Size size, {required double intensity}) {
    final count = (52 * particleScale * intensity).round().clamp(20, 80);
    final random = math.Random(7);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38 + intensity * 0.12)
      ..strokeWidth = 1.6 + intensity * 0.4
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < count; i++) {
      final seed = random.nextDouble();
      final x = seed * size.width;
      final speed = (0.55 + random.nextDouble() * 0.7) * intensity;
      final y = ((seed * size.height * 1.2) + phase * size.height * speed) % (size.height + 24) - 12;
      final length = (10 + random.nextDouble() * 14) * intensity;
      canvas.drawLine(Offset(x, y), Offset(x - 4, y + length), paint);
    }
  }

  void _paintSnowfall(Canvas canvas, Size size) {
    final count = (42 * particleScale).round().clamp(16, 56);
    final random = math.Random(11);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.82);

    for (var i = 0; i < count; i++) {
      final seed = random.nextDouble();
      final drift = math.sin(phase * math.pi * 2 + seed * 8) * 8;
      final x = (seed * size.width + drift) % size.width;
      final y = ((seed * size.height * 1.1) + phase * size.height * 0.35) % (size.height + 10);
      canvas.drawCircle(Offset(x, y), 1.2 + random.nextDouble() * 2.2, paint);
    }
  }

  void _paintSnowCap(Canvas canvas, Rect car) {
    final cap = RRect.fromRectAndRadius(
      Rect.fromLTWH(car.left + car.width * 0.18, car.top + car.height * 0.02, car.width * 0.64, car.height * 0.14),
      Radius.circular(car.height * 0.08),
    );
    canvas.drawRRect(
      cap,
      Paint()
        ..shader = ui.Gradient.linear(
          cap.outerRect.topLeft,
          cap.outerRect.bottomCenter,
          [Colors.white.withValues(alpha: 0.24), Colors.white.withValues(alpha: 0.05)],
        ),
    );
  }

  void _paintHeadlights(Canvas canvas, Rect car) {
    final pulse = 0.86 + math.sin(phase * math.pi * 2) * 0.07;
    for (final origin in [
      Offset(car.left + car.width * 0.18, car.bottom - car.height * 0.18),
      Offset(car.right - car.width * 0.18, car.bottom - car.height * 0.18),
    ]) {
      canvas.drawCircle(
        origin,
        car.width * 0.14,
        Paint()
          ..shader = ui.Gradient.radial(
            origin,
            car.width * 0.14,
            [
              const Color(0xFFFFF2CC).withValues(alpha: 0.30 * pulse),
              accent.withValues(alpha: 0.10 * pulse),
              Colors.transparent,
            ],
            const [0.0, 0.45, 1.0],
          ),
      );
      canvas.drawCircle(origin, 4.5, Paint()..color = const Color(0xFFFFF7E6).withValues(alpha: 0.88 * pulse));
    }
  }

  void _paintStormFlash(Canvas canvas, Size size) {
    final flashWave = math.sin(phase * math.pi * 2);
    if (flashWave < 0.92) return;
    final alpha = (flashWave - 0.92) * 1.4;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 0.14)),
    );
  }

  @override
  bool shouldRepaint(covariant WeatherVehicleAtmospherePainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.layer != layer ||
      oldDelegate.phase != phase ||
      oldDelegate.accent != accent ||
      oldDelegate.particleScale != particleScale;
}
