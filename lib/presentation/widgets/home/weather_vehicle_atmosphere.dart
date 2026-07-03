import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/enums/driviq_weather_mood.dart';

enum WeatherAtmosphereLayer { behindVehicle, inFrontOfVehicle }

class WeatherVehicleAtmosphere extends StatefulWidget {
  const WeatherVehicleAtmosphere({
    super.key,
    required this.mood,
    required this.layer,
    this.effectsEnabled = false,
    this.accentColor,
  });

  final DriviqWeatherMood mood;
  final WeatherAtmosphereLayer layer;
  final bool effectsEnabled;
  final Color? accentColor;

  @override
  State<WeatherVehicleAtmosphere> createState() => _WeatherVehicleAtmosphereState();
}

class _WeatherVehicleAtmosphereState extends State<WeatherVehicleAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    if (widget.effectsEnabled) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant WeatherVehicleAtmosphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.effectsEnabled && !_ctrl.isAnimating) _ctrl.repeat();
    if (!widget.effectsEnabled && _ctrl.isAnimating) _ctrl.stop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.effectsEnabled) return const SizedBox.expand();
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => CustomPaint(
            painter: _WeatherPainter(
              mood: widget.mood,
              layer: widget.layer,
              t: _ctrl.value,
              accent: widget.accentColor ?? const Color(0xFF37E7FF),
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _WeatherPainter extends CustomPainter {
  const _WeatherPainter({
    required this.mood,
    required this.layer,
    required this.t,
    required this.accent,
  });

  final DriviqWeatherMood mood;
  final WeatherAtmosphereLayer layer;
  final double t;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case DriviqWeatherMood.rain:
        _rain(canvas, size, count: layer == WeatherAtmosphereLayer.inFrontOfVehicle ? 42 : 24, alpha: 0.34);
        _wetGlass(canvas, size);
      case DriviqWeatherMood.storm:
        _rain(canvas, size, count: layer == WeatherAtmosphereLayer.inFrontOfVehicle ? 70 : 36, alpha: 0.46);
        if (layer == WeatherAtmosphereLayer.behindVehicle && t < 0.06) _flash(canvas, size);
        _wetGlass(canvas, size);
      case DriviqWeatherMood.snow:
        _snow(canvas, size, count: layer == WeatherAtmosphereLayer.inFrontOfVehicle ? 38 : 24);
      case DriviqWeatherMood.fog:
        _fog(canvas, size);
      case DriviqWeatherMood.clearDay:
        if (layer == WeatherAtmosphereLayer.behindVehicle) _sun(canvas, size);
      case DriviqWeatherMood.clearNight:
        if (layer == WeatherAtmosphereLayer.behindVehicle) _nightGlow(canvas, size);
      case DriviqWeatherMood.cloudy:
        if (layer == WeatherAtmosphereLayer.behindVehicle) _cloudSoftness(canvas, size);
      case DriviqWeatherMood.unknown:
        if (layer == WeatherAtmosphereLayer.behindVehicle) _neutral(canvas, size);
    }
  }

  void _rain(Canvas canvas, Size size, {required int count, required double alpha}) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final seed = (i * 37.13) % 1.0;
      final x = ((i * 73.0) % size.width) + math.sin(i) * 18;
      final y = ((seed + t * (0.9 + (i % 5) * 0.08)) % 1.0) * size.height;
      canvas.drawLine(Offset(x, y), Offset(x - 10, y + 32), p);
    }
  }

  void _snow(Canvas canvas, Size size, {required int count}) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.72);
    for (var i = 0; i < count; i++) {
      final x = ((i * 61.0) % size.width) + math.sin(t * math.pi * 2 + i) * 18;
      final y = (((i * 0.071) + t * (0.12 + (i % 4) * 0.025)) % 1.0) * size.height;
      canvas.drawCircle(Offset(x, y), 1.4 + (i % 3) * 0.7, p);
    }
  }

  void _fog(Canvas canvas, Size size) {
    final p = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: layer == WeatherAtmosphereLayer.inFrontOfVehicle ? 0.07 : 0.12),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, p);
  }

  void _sun(Canvas canvas, Size size) {
    final p = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD38A).withValues(alpha: 0.22),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.78, size.height * 0.16), radius: size.width * 0.45));
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.16), size.width * 0.45, p);
  }

  void _nightGlow(Canvas canvas, Size size) {
    final p = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: 0.13), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.62), radius: size.width * 0.55));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.62), size.width * 0.55, p);
  }

  void _cloudSoftness(Canvas canvas, Size size) {
    final p = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.055), Colors.transparent],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, p);
  }

  void _neutral(Canvas canvas, Size size) {
    final p = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: 0.08), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.35), radius: size.width * 0.7));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.35), size.width * 0.7, p);
  }

  void _wetGlass(Canvas canvas, Size size) {
    if (layer != WeatherAtmosphereLayer.behindVehicle) return;
    final p = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, accent.withValues(alpha: 0.08), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, size.height * 0.56, size.width, size.height * 0.26));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.56, size.width, size.height * 0.26), p);
  }

  void _flash(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white.withValues(alpha: 0.10 * (1 - t / 0.06)));
  }

  @override
  bool shouldRepaint(covariant _WeatherPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.mood != mood || oldDelegate.layer != layer || oldDelegate.accent != accent;
  }
}
