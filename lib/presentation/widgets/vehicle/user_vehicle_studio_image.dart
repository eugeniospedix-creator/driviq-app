import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/enums/driviq_weather_mood.dart';
import '../home/weather_vehicle_atmosphere.dart';

/// Premium static studio presentation of the user's vehicle photo (2D cutout).
class UserVehicleStudioImage extends StatelessWidget {
  const UserVehicleStudioImage({
    super.key,
    required this.vehicle,
    this.accent = DQ.cyan,
    this.mood,
    this.showReflection = true,
    this.weatherEffectsEnabled = false,
    this.onAddPhoto,
    this.compact = false,
  });

  final Vehicle vehicle;
  final Color accent;
  final DriviqWeatherMood? mood;
  final bool showReflection;
  final bool weatherEffectsEnabled;
  final VoidCallback? onAddPhoto;
  final bool compact;

  bool get _hasPhoto {
    final path = vehicle.photoPath;
    return path != null && path.isNotEmpty && File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPhoto) {
      return _PhotoPlaceholder(
        compact: compact,
        onAddPhoto: onAddPhoto,
      );
    }

    final path = vehicle.photoPath!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final carH = h * (compact ? 0.72 : 0.78);
        final carW = w * 0.92;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              bottom: h * 0.08,
              child: _FloorShadow(
                width: carW * 0.88,
                accent: accent,
                mood: mood,
                weatherEffectsEnabled: weatherEffectsEnabled,
              ),
            ),
            if (showReflection)
              Positioned(
                top: h * 0.52,
                child: _VehicleReflection(
                  path: path,
                  width: carW,
                  height: carH * 0.22,
                  accent: accent,
                  mood: mood,
                  weatherEffectsEnabled: weatherEffectsEnabled,
                ),
              ),
            Positioned(
              top: h * 0.08,
              child: _VehicleCutout(
                path: path,
                width: carW,
                height: carH,
                accent: accent,
                mood: mood,
                weatherEffectsEnabled: weatherEffectsEnabled,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VehicleCutout extends StatelessWidget {
  const _VehicleCutout({
    required this.path,
    required this.width,
    required this.height,
    required this.accent,
    required this.mood,
    required this.weatherEffectsEnabled,
  });

  final String path;
  final double width;
  final double height;
  final Color accent;
  final DriviqWeatherMood? mood;
  final bool weatherEffectsEnabled;

  @override
  Widget build(BuildContext context) {
    final wet = weatherEffectsEnabled &&
        (mood == DriviqWeatherMood.rain || mood == DriviqWeatherMood.storm);
    final snowy = weatherEffectsEnabled && mood == DriviqWeatherMood.snow;
    final night = mood == DriviqWeatherMood.clearNight;
    final clear = mood == DriviqWeatherMood.clearDay;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Image.file(
            File(path),
            key: ValueKey(path),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.5, -1),
                  end: const Alignment(0.5, 1),
                  colors: [
                    (clear ? const Color(0xFFFFD38A) : accent).withValues(alpha: 0.14),
                    Colors.transparent,
                    Colors.black.withValues(alpha: wet ? 0.22 : night ? 0.24 : 0.08),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          if (wet)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.transparent,
                      accent.withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
            ),
          if (snowy)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          if (weatherEffectsEnabled && mood != null)
            Positioned.fill(
              child: IgnorePointer(
                child: WeatherVehicleAtmosphere(
                  mood: mood!,
                  layer: WeatherAtmosphereLayer.inFrontOfVehicle,
                  accentColor: accent,
                  effectsEnabled: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VehicleReflection extends StatelessWidget {
  const _VehicleReflection({
    required this.path,
    required this.width,
    required this.height,
    required this.accent,
    required this.mood,
    required this.weatherEffectsEnabled,
  });

  final String path;
  final double width;
  final double height;
  final Color accent;
  final DriviqWeatherMood? mood;
  final bool weatherEffectsEnabled;

  @override
  Widget build(BuildContext context) {
    final wet = weatherEffectsEnabled &&
        (mood == DriviqWeatherMood.rain || mood == DriviqWeatherMood.storm);
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.42,
        child: Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.rotationX(3.141592653589793),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: wet ? 0.42 : 0.34),
                Colors.transparent,
              ],
            ).createShader(rect),
            child: Opacity(
              opacity: wet ? 0.28 : 0.20,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(accent.withValues(alpha: 0.12), BlendMode.srcATop),
                child: Image.file(
                  File(path),
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloorShadow extends StatelessWidget {
  const _FloorShadow({
    required this.width,
    required this.accent,
    required this.mood,
    required this.weatherEffectsEnabled,
  });

  final double width;
  final Color accent;
  final DriviqWeatherMood? mood;
  final bool weatherEffectsEnabled;

  @override
  Widget build(BuildContext context) {
    final wet = weatherEffectsEnabled &&
        (mood == DriviqWeatherMood.rain || mood == DriviqWeatherMood.storm);
    final snowy = weatherEffectsEnabled && mood == DriviqWeatherMood.snow;
    return Container(
      width: width,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: RadialGradient(
          colors: [
            Colors.black.withValues(alpha: wet ? 0.68 : snowy ? 0.58 : 0.52),
            (wet ? accent : snowy ? Colors.white : accent).withValues(alpha: wet ? 0.20 : snowy ? 0.10 : 0.06),
            Colors.transparent,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.compact, this.onAddPhoto});

  final bool compact;
  final VoidCallback? onAddPhoto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onAddPhoto,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: compact ? 12 : 24),
          padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24, vertical: compact ? 20 : 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DQ.radiusLg),
            border: Border.all(color: DQ.cyan.withValues(alpha: 0.28)),
            color: Colors.white.withValues(alpha: 0.03),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_a_photo_rounded,
                color: DQ.cyan.withValues(alpha: 0.85),
                size: compact ? 28 : 36,
              ),
              SizedBox(height: compact ? 8 : 12),
              Text(
                'Add your vehicle photo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DQ.textPrimary.withValues(alpha: 0.92),
                  fontSize: compact ? 13 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 6),
                const Text(
                  'Camera or gallery — used in your studio profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DQ.textMuted, fontSize: 12, height: 1.35),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
