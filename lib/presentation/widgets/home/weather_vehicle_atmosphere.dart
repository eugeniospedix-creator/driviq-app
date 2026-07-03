import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/enums/driviq_weather_mood.dart';

enum WeatherAtmosphereLayer { behindVehicle, inFrontOfVehicle }

/// Lightweight weather mood overlay for the Home vehicle hero.
class WeatherVehicleAtmosphere extends StatefulWidget {
  const WeatherVehicleAtmosphere({
    super.key,
    required this.mood,
    required this.height,
    required this.effectsEnabled,
    required this.layer,
    this.accentColor,
  });

  final DriviqWeatherMood mood;
  final double height;
  final bool effectsEnabled;
  final WeatherAtmosphereLayer layer;
  final Color? accentColor;

  @override
  State<WeatherVehicleAtmosphere> createState() => _WeatherVehicleAtmosphereState();
}

class _WeatherVehicleAtmosphereState extends State<WeatherVehicleAtmosphere> with SingleTickerProviderStateMixin {
  AnimationController? _phase;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant WeatherVehicleAtmosphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood || oldWidget.effectsEnabled != widget.effectsEnabled) {
      _syncController();
    }
  }

  void _syncController() {
    final shouldRun = widget.effectsEnabled &&
        (widget.mood.usesParticles || widget.mood == DriviqWeatherMood.night) &&
        !_reduceMotion;
    if (shouldRun) {
      _phase ??= AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
      if (!_phase!.isAnimating) _phase!.repeat();
    } else {
      _phase?.dispose();
      _phase = null;
    }
  }

  bool get _reduceMotion {
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    return dispatcher.accessibilityFeatures.disableAnimations;
  }

  @override
  void dispose() {
    _phase?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.effectsEnabled || widget.mood == DriviqWeatherMood.studio) {
      return const SizedBox.shrink();
    }

    final accent = widget.accentColor ?? DQ.cyan;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _phase ?? const AlwaysStoppedAnimation(0),
        builder: (context, _) {
          return CustomPaint(
            painter: _WeatherAtmospherePainter(
              mood: widget.mood,
              layer: widget.layer,
              phase: _phase?.value ?? 0,
              accent: accent,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _WeatherAtmospherePainter extends CustomPainter {
  _WeatherAtmospherePainter({
    required this.mood,
    required this.layer,
    required this.phase,
    required this.accent,
  });

  final DriviqWeatherMood mood;
  final WeatherAtmosphereLayer layer;
  final double phase;
  final Color accent;

  static const _warmSun = Color(0xFFFFB86A);
  static const _coolSky = Color(0xFF8BA4BC);
  static const _nightBlue = Color(0xFF0A1420);

  Rect _carBounds(Size size) {
    return Rect.fromLTWH(size.width * 0.07, size.height * 0.16, size.width * 0.86, size.height * 0.50);
  }

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
    if (layer == WeatherAtmosphereLayer.behindVehicle) {
      _paintAmbient(canvas, size);
    } else {
      _paintForeground(canvas, size);
    }
  }

  void _paintAmbient(Canvas canvas, Size size) {
    switch (mood) {
      case DriviqWeatherMood.sunny:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.radial(
              Offset(size.width * 0.22, size.height * 0.12),
              size.width * 0.75,
              [
                _warmSun.withValues(alpha: 0.16),
                _warmSun.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              [0.0, 0.35, 1.0],
            ),
        );
      case DriviqWeatherMood.cloudy:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, 0),
              Offset(size.width, size.height),
              [
                _coolSky.withValues(alpha: 0.14),
                const Color(0xFF1A2430).withValues(alpha: 0.22),
                Colors.transparent,
              ],
            ),
        );
      case DriviqWeatherMood.rainy:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.linear(
              const Offset(0, 0),
              Offset(0, size.height),
              [
                const Color(0xFF101820).withValues(alpha: 0.35),
                const Color(0xFF0A1018).withValues(alpha: 0.18),
                Colors.transparent,
              ],
            ),
        );
      case DriviqWeatherMood.snowy:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, 0),
              Offset(0, size.height),
              [
                const Color(0xFFDCE6F0).withValues(alpha: 0.10),
                const Color(0xFF1A2430).withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ),
        );
      case DriviqWeatherMood.foggy:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, size.height * 0.08),
              Offset(0, size.height * 0.72),
              [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.06),
              ],
            ),
        );
      case DriviqWeatherMood.night:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, 0),
              Offset(0, size.height),
              [
                _nightBlue.withValues(alpha: 0.55),
                DQ.voidBlack.withValues(alpha: 0.25),
                Colors.transparent,
              ],
            ),
        );
      case DriviqWeatherMood.studio:
        break;
    }
  }

  void _paintForeground(Canvas canvas, Size size) {
    final car = _carBounds(size);

    switch (mood) {
      case DriviqWeatherMood.sunny:
        _paintBodyGloss(canvas, car, Colors.white.withValues(alpha: 0.14), warm: true);
      case DriviqWeatherMood.cloudy:
        _paintBodyGloss(canvas, car, _coolSky.withValues(alpha: 0.10), warm: false);
      case DriviqWeatherMood.rainy:
        _paintRain(canvas, size);
        _paintWetFloor(canvas, size);
        _paintBodyGloss(canvas, car, Colors.white.withValues(alpha: 0.08), warm: false);
      case DriviqWeatherMood.snowy:
        _paintSnowfall(canvas, size);
        _paintSnowCap(canvas, car);
        _paintBodyGloss(canvas, car, Colors.white.withValues(alpha: 0.12), warm: false);
      case DriviqWeatherMood.foggy:
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = ui.Gradient.radial(
              Offset(size.width * 0.5, size.height * 0.42),
              size.width * 0.72,
              [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
        );
      case DriviqWeatherMood.night:
        _paintHeadlights(canvas, car);
        _paintBodyGloss(canvas, car, accent.withValues(alpha: 0.10), warm: false);
        _paintWetFloor(canvas, size, tint: accent.withValues(alpha: 0.18));
      case DriviqWeatherMood.studio:
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
        ..shader = ui.Gradient.linear(
          highlight.topLeft,
          highlight.bottomRight,
          [
            tint,
            Colors.transparent,
          ],
        ),
    );

    if (warm) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(car.left + car.width * 0.08, car.top + car.height * 0.42, car.width * 0.35, car.height * 0.12),
          const Radius.circular(20),
        ),
        Paint()..color = _warmSun.withValues(alpha: 0.08),
      );
    }
  }

  void _paintWetFloor(Canvas canvas, Size size, {Color? tint}) {
    final floor = _floorBounds(size);
    final shimmer = math.sin(phase * math.pi * 2) * 0.04;

    canvas.drawOval(
      floor.inflate(size.height * 0.01),
      Paint()
        ..shader = ui.Gradient.radial(
          floor.center,
          floor.width * 0.5,
          [
            (tint ?? Colors.white.withValues(alpha: 0.16 + shimmer)),
            Colors.transparent,
          ],
        ),
    );
  }

  void _paintRain(Canvas canvas, Size size) {
    final random = math.Random(7);
    const count = 34;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < count; i++) {
      final seed = random.nextDouble();
      final x = seed * size.width;
      final speed = 0.55 + random.nextDouble() * 0.7;
      final y = ((seed * size.height * 1.2) + phase * size.height * speed) % (size.height + 24) - 12;
      final length = 10 + random.nextDouble() * 14;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + length), paint);
    }
  }

  void _paintSnowfall(Canvas canvas, Size size) {
    final random = math.Random(11);
    const count = 28;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.55);

    for (var i = 0; i < count; i++) {
      final seed = random.nextDouble();
      final drift = math.sin(phase * math.pi * 2 + seed * 8) * 8;
      final x = (seed * size.width + drift) % size.width;
      final y = ((seed * size.height * 1.1) + phase * size.height * 0.35) % (size.height + 10);
      final r = 1.2 + random.nextDouble() * 2.2;
      canvas.drawCircle(Offset(x, y), r, paint);
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
          [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
    );
  }

  void _paintHeadlights(Canvas canvas, Rect car) {
    final pulse = 0.85 + math.sin(phase * math.pi * 2) * 0.08;
    final left = Offset(car.left + car.width * 0.18, car.bottom - car.height * 0.18);
    final right = Offset(car.right - car.width * 0.18, car.bottom - car.height * 0.18);

    for (final origin in [left, right]) {
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(origin.dx - car.width * 0.12, origin.dy + car.height * 0.42)
        ..lineTo(origin.dx + car.width * 0.12, origin.dy + car.height * 0.42)
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.radial(
            origin,
            car.width * 0.22,
            [
              const Color(0xFFFFF2CC).withValues(alpha: 0.28 * pulse),
              accent.withValues(alpha: 0.10 * pulse),
              Colors.transparent,
            ],
          ),
      );

      canvas.drawCircle(
        origin,
        4.5,
        Paint()..color = const Color(0xFFFFF7E6).withValues(alpha: 0.85 * pulse),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherAtmospherePainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.layer != layer ||
      oldDelegate.phase != phase ||
      oldDelegate.accent != accent;
}
