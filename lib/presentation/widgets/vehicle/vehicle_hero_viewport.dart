import 'package:flutter/material.dart';

import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/vehicle_studio_model.dart';
import '../../../domain/enums/driviq_weather_mood.dart';
import 'interactive_user_vehicle_model.dart';

/// Aspect-ratio viewport — stable user photo studio (never Kenney/GLB fallback).
class VehicleHeroViewport extends StatelessWidget {
  const VehicleHeroViewport({
    super.key,
    required this.vehicle,
    this.aspectRatio = 2.15,
    this.accent = const Color(0xFF19D6FF),
    this.mood,
    this.onAddPhoto,
    this.interactive = true,
    this.weatherEffectsEnabled = false,
  });

  final Vehicle vehicle;
  final double aspectRatio;
  final Color accent;
  final DriviqWeatherMood? mood;
  final VoidCallback? onAddPhoto;
  final bool interactive;
  final bool weatherEffectsEnabled;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRect(
        child: InteractiveUserVehicleModel(
          model: VehicleStudioModel.fromVehicle(vehicle),
          accent: accent,
          mood: mood,
          weatherEffectsEnabled: weatherEffectsEnabled,
          onAddPhoto: onAddPhoto,
          compact: aspectRatio < 2.0,
          interactive: interactive,
        ),
      ),
    );
  }
}
