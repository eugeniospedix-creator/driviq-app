import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/enums/driviq_weather_mood.dart';
import 'vehicle_hero_viewport.dart';
import 'vehicle_weather_scene.dart';

/// Luxury studio stage for the user's vehicle photo — stable, centered.
class VehicleHeroStage extends StatelessWidget {
  const VehicleHeroStage({
    super.key,
    required this.vehicle,
    this.height,
    this.faults = const [],
    this.scanning = false,
    this.interactive = true,
    this.showGlow = true,
    this.compact = false,
    this.highlightColor,
    this.borderRadius = 0,
    this.onAddPhoto,
    this.mood,
    this.weatherEffectsEnabled = false,
  });

  final Vehicle vehicle;
  final double? height;
  final List<ComponentFault> faults;
  final bool scanning;
  final bool interactive;
  final bool showGlow;
  final bool compact;
  final Color? highlightColor;
  final double borderRadius;
  final VoidCallback? onAddPhoto;
  final DriviqWeatherMood? mood;
  final bool weatherEffectsEnabled;

  @override
  Widget build(BuildContext context) {
    final accent = highlightColor ?? DQ.cyan;
    final h = height ?? (compact ? 190.0 : 330.0);

    return SizedBox(
      height: h,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [DQ.graphite2, DQ.voidBlack, DQ.voidBlack],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              top: -h * 0.12,
              left: -h * 0.18,
              right: -h * 0.18,
              height: h * 0.78,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.86,
                    colors: [
                      accent.withValues(alpha: scanning ? 0.16 : 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: h * 0.08,
              right: h * 0.08,
              bottom: compact ? h * 0.20 : h * 0.18,
              child: Container(
                height: compact ? h * 0.07 : h * 0.085,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: RadialGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.50),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 36,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 18 : 22,
                compact ? 18 : 24,
                compact ? 18 : 22,
                compact ? 28 : 34,
              ),
              child: RepaintBoundary(
                child: VehicleWeatherScene(
                mood: mood,
                accent: accent,
                effectsEnabled: weatherEffectsEnabled,
                child: VehicleHeroViewport(
                  vehicle: vehicle,
                  aspectRatio: compact ? 1.95 : 2.15,
                  accent: accent,
                  mood: mood,
                  weatherEffectsEnabled: weatherEffectsEnabled,
                  onAddPhoto: onAddPhoto,
                  interactive: interactive,
                ),
              ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.05,
                    colors: [
                      Colors.transparent,
                      DQ.voidBlack.withValues(alpha: compact ? 0.08 : 0.18),
                    ],
                    stops: const [0.75, 1.0],
                  ),
                ),
              ),
            ),
            if (!compact)
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
                      colors: [Colors.transparent, DQ.voidBlack.withValues(alpha: 0.75)],
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
