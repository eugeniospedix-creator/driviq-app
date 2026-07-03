import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/home_weather_context.dart';
import '../../../domain/entities/vehicle.dart';
import '../vehicle/vehicle_hero_viewport.dart';
import 'weather_vehicle_atmosphere.dart';

/// Home hero vehicle — stable Kenney viewport + optional weather atmosphere.
class HomeVehicleHero extends StatelessWidget {
  const HomeVehicleHero({
    super.key,
    required this.vehicle,
    required this.height,
    this.highlightColor,
    this.weather = HomeWeatherContext.fallback,
  });

  final Vehicle vehicle;
  final double height;
  final Color? highlightColor;
  final HomeWeatherContext weather;

  @override
  Widget build(BuildContext context) {
    final accent = highlightColor ?? DQ.cyan;
    final h = height;
    final viewportHeight = h * 0.66;

    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [DQ.graphite2, DQ.voidBlack, DQ.voidBlack],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned.fill(
            child: WeatherVehicleAtmosphere(
              mood: weather.mood,
              effectsEnabled: weather.effectsEnabled,
              layer: WeatherAtmosphereLayer.behindVehicle,
              accentColor: accent,
            ),
          ),
          Positioned(
            left: h * 0.08,
            right: h * 0.08,
            bottom: h * 0.26,
            child: Container(
              height: h * 0.04,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: viewportHeight,
              width: double.infinity,
              child: VehicleHeroViewport(
                vehicle: vehicle,
                enableIdleMotion: true,
              ),
            ),
          ),
          Positioned.fill(
            child: WeatherVehicleAtmosphere(
              mood: weather.mood,
              effectsEnabled: weather.effectsEnabled,
              layer: WeatherAtmosphereLayer.inFrontOfVehicle,
              accentColor: accent,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: h * 0.32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    DQ.voidBlack.withValues(alpha: 0.55),
                    DQ.voidBlack.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
