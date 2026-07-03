import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/vehicle_studio_model.dart';
import '../../../domain/enums/driviq_weather_mood.dart';
import 'interactive_user_vehicle_model.dart';
import 'vehicle_weather_scene.dart';

/// Studio-framed vehicle — stable user photo 2.5D, optional fault hotspots.
class DriviqStudioVehicle extends StatelessWidget {
  const DriviqStudioVehicle({
    super.key,
    required this.vehicle,
    required this.height,
    this.highlightColor,
    this.showLiveAtmosphere = true,
    this.interactive = false,
    this.faults = const [],
    this.highlightedFault,
    this.onFaultSelected,
    this.onAddPhoto,
    this.mood,
    this.weatherEffectsEnabled = false,
  });

  final Vehicle vehicle;
  final double height;
  final Color? highlightColor;
  final bool showLiveAtmosphere;
  final bool interactive;
  final List<ComponentFault> faults;
  final ComponentFault? highlightedFault;
  final ValueChanged<ComponentFault>? onFaultSelected;
  final VoidCallback? onAddPhoto;
  final DriviqWeatherMood? mood;
  final bool weatherEffectsEnabled;

  @override
  Widget build(BuildContext context) {
    final accent = highlightColor ?? DQ.cyan;
    final h = height;
    final viewportHeight = h * 0.82;

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
                colors: [Color(0xFF1C2632), DQ.voidBlack, DQ.voidBlack],
                stops: [0.0, 0.42, 1.0],
              ),
            ),
          ),
          if (showLiveAtmosphere)
            Positioned(
              top: h * 0.06,
              left: h * 0.03,
              right: h * 0.03,
              height: h * 0.50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.1),
                    radius: 0.95,
                    colors: [accent.withValues(alpha: 0.08), Colors.transparent],
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: viewportHeight,
              width: double.infinity,
              child: ClipRect(
                child: VehicleWeatherScene(
                  mood: mood,
                  accent: accent,
                  effectsEnabled: weatherEffectsEnabled,
                  child: InteractiveUserVehicleModel(
                    model: VehicleStudioModel.fromVehicle(vehicle),
                    accent: accent,
                    mood: mood,
                    showReflection: true,
                    interactive: interactive,
                    weatherEffectsEnabled: weatherEffectsEnabled,
                    faults: faults,
                    highlightedFault: highlightedFault,
                    onFaultSelected: onFaultSelected,
                    onAddPhoto: onAddPhoto,
                  ),
                ),
              ),
            ),
          ),
          if (showLiveAtmosphere)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: h * 0.30,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      DQ.voidBlack.withValues(alpha: 0.55),
                      DQ.voidBlack.withValues(alpha: 0.94),
                    ],
                    stops: const [0.0, 0.50, 1.0],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
