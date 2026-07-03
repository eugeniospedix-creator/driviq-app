import 'package:flutter/material.dart';

import '../../../domain/enums/driviq_weather_mood.dart';
import '../home/weather_vehicle_atmosphere.dart';

/// Layers live weather effects over a vehicle scene (behind + in front).
class VehicleWeatherScene extends StatelessWidget {
  const VehicleWeatherScene({
    super.key,
    required this.child,
    this.mood,
    this.accent = const Color(0xFF19D6FF),
    this.effectsEnabled = false,
  });

  final Widget child;
  final DriviqWeatherMood? mood;
  final Color accent;
  final bool effectsEnabled;

  @override
  Widget build(BuildContext context) {
    if (mood == null || !effectsEnabled) return child;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        WeatherVehicleAtmosphere(
          mood: mood!,
          effectsEnabled: effectsEnabled,
          layer: WeatherAtmosphereLayer.behindVehicle,
          accentColor: accent,
        ),
        child,
        WeatherVehicleAtmosphere(
          mood: mood!,
          effectsEnabled: effectsEnabled,
          layer: WeatherAtmosphereLayer.inFrontOfVehicle,
          accentColor: accent,
        ),
      ],
    );
  }
}
