import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/enums/driviq_weather_mood.dart';
import 'weather_vehicle_atmosphere_painter.dart';

export 'weather_vehicle_atmosphere_painter.dart' show WeatherAtmosphereLayer;

/// Lightweight weather mood overlay for the Home vehicle hero.
class WeatherVehicleAtmosphere extends StatefulWidget {
  const WeatherVehicleAtmosphere({
    super.key,
    required this.mood,
    required this.effectsEnabled,
    required this.layer,
    this.accentColor,
  });

  final DriviqWeatherMood mood;
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
    final needsMotion = widget.effectsEnabled &&
        (widget.mood.isAnimated || widget.mood == DriviqWeatherMood.clearNight || widget.mood == DriviqWeatherMood.storm) &&
        !_reduceMotion;

    if (needsMotion) {
      _phase ??= AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
      if (!_phase!.isAnimating) _phase!.repeat();
    } else {
      _phase?.dispose();
      _phase = null;
    }
  }

  bool get _reduceMotion =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;

  double get _particleScale {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    if (ratio > 3.0) return 0.75;
    if (ratio > 2.5) return 0.88;
    return 1.0;
  }

  @override
  void dispose() {
    _phase?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.effectsEnabled) return const SizedBox.shrink();

    final accent = widget.accentColor ?? DQ.cyan;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _phase ?? const AlwaysStoppedAnimation(0),
        builder: (context, _) {
          return CustomPaint(
            painter: WeatherVehicleAtmospherePainter(
              mood: widget.mood,
              layer: widget.layer,
              phase: _phase?.value ?? 0,
              accent: accent,
              particleScale: _particleScale,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}
