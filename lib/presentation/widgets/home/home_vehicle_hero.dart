import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/home_weather_context.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/enums/driviq_weather_mood.dart';
import '../../../domain/entities/vehicle_studio_model.dart';
import '../vehicle/interactive_user_vehicle_model.dart';
import 'weather_vehicle_atmosphere.dart';

class HomeVehicleHero extends StatelessWidget {
  const HomeVehicleHero({
    super.key,
    required this.vehicle,
    required this.height,
    this.highlightColor,
    this.weather = HomeWeatherContext.fallback,
    this.onAddPhoto,
  });

  final Vehicle vehicle;
  final double height;
  final Color? highlightColor;
  final HomeWeatherContext weather;
  final VoidCallback? onAddPhoto;

  @override
  Widget build(BuildContext context) {
    final accent = highlightColor ?? DQ.cyan;
    final mood = weather.mood;
    final h = height.clamp(320.0, 760.0);

    return SizedBox(
      height: h,
      width: double.infinity,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _WeatherStudioBackdrop(mood: mood, accent: accent),
            _StudioFloor(mood: mood, accent: accent, weatherEffectsEnabled: weather.showEffects),
            WeatherVehicleAtmosphere(
              mood: mood,
              effectsEnabled: weather.showEffects,
              layer: WeatherAtmosphereLayer.behindVehicle,
              accentColor: accent,
            ),
            Center(
              child: RepaintBoundary(
                child: SizedBox(
                  height: h * 0.62,
                  width: double.infinity,
                  child: InteractiveUserVehicleModel(
                    model: VehicleStudioModel.fromVehicle(vehicle),
                    accent: accent,
                    mood: mood,
                    weatherEffectsEnabled: weather.showEffects,
                    interactive: true,
                    onAddPhoto: onAddPhoto,
                  ),
                ),
              ),
            ),
            WeatherVehicleAtmosphere(
              mood: mood,
              effectsEnabled: weather.showEffects,
              layer: WeatherAtmosphereLayer.inFrontOfVehicle,
              accentColor: accent,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: h * 0.28,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      DQ.voidBlack.withValues(alpha: 0.70),
                      DQ.voidBlack,
                    ],
                    stops: const [0.0, 0.56, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherStudioBackdrop extends StatelessWidget {
  const _WeatherStudioBackdrop({required this.mood, required this.accent});

  final DriviqWeatherMood mood;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = switch (mood) {
      DriviqWeatherMood.clearDay => const [Color(0xFF203149), Color(0xFF0D1825), Color(0xFF03060A)],
      DriviqWeatherMood.clearNight => const [Color(0xFF07111F), Color(0xFF040911), Color(0xFF020407)],
      DriviqWeatherMood.cloudy => const [Color(0xFF172330), Color(0xFF0B121B), Color(0xFF03060A)],
      DriviqWeatherMood.rain || DriviqWeatherMood.storm => const [Color(0xFF0A1420), Color(0xFF050A10), Color(0xFF020407)],
      DriviqWeatherMood.snow => const [Color(0xFF223247), Color(0xFF0E1722), Color(0xFF05080D)],
      DriviqWeatherMood.fog => const [Color(0xFF1B2732), Color(0xFF0D141C), Color(0xFF05080D)],
      DriviqWeatherMood.unknown => const [Color(0xFF142131), Color(0xFF071019), Color(0xFF03060A)],
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.12, -0.28),
            radius: 0.9,
            colors: [accent.withValues(alpha: 0.18), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _StudioFloor extends StatelessWidget {
  const _StudioFloor({
    required this.mood,
    required this.accent,
    required this.weatherEffectsEnabled,
  });

  final DriviqWeatherMood mood;
  final Color accent;
  final bool weatherEffectsEnabled;

  @override
  Widget build(BuildContext context) {
    final wet = weatherEffectsEnabled &&
        (mood == DriviqWeatherMood.rain || mood == DriviqWeatherMood.storm);
    final snowy = weatherEffectsEnabled && mood == DriviqWeatherMood.snow;
    return Align(
      alignment: const Alignment(0, 0.36),
      child: FractionallySizedBox(
        widthFactor: 0.92,
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: RadialGradient(
              colors: [
                (wet ? accent : snowy ? Colors.white : Colors.black)
                    .withValues(alpha: wet ? 0.22 : snowy ? 0.13 : 0.45),
                Colors.transparent,
              ],
            ),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.46), blurRadius: 40, spreadRadius: 6)],
          ),
        ),
      ),
    );
  }
}
