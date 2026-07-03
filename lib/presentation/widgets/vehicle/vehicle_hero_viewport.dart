import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/vehicle_artwork_paths.dart';
import '../../../domain/entities/vehicle.dart';

/// Stable, centered vehicle stage — fixed aspect ratio, no lateral drift.
class VehicleHeroViewport extends StatefulWidget {
  const VehicleHeroViewport({
    super.key,
    required this.vehicle,
    this.enableIdleMotion = true,
    this.aspectRatio = 2.15,
  });

  final Vehicle vehicle;
  final bool enableIdleMotion;
  final double aspectRatio;

  @override
  State<VehicleHeroViewport> createState() => _VehicleHeroViewportState();
}

class _VehicleHeroViewportState extends State<VehicleHeroViewport> with SingleTickerProviderStateMixin {
  AnimationController? _idle;

  @override
  void initState() {
    super.initState();
    _syncIdle();
  }

  @override
  void didUpdateWidget(covariant VehicleHeroViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enableIdleMotion != widget.enableIdleMotion) _syncIdle();
  }

  void _syncIdle() {
    final shouldRun = widget.enableIdleMotion && !_reduceMotion;
    if (shouldRun) {
      _idle ??= AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    } else {
      _idle?.dispose();
      _idle = null;
    }
  }

  bool get _reduceMotion =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;

  @override
  void dispose() {
    _idle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroPath = VehicleArtworkPaths.heroFor(widget.vehicle);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        var width = maxW;
        var height = width / widget.aspectRatio;
        if (height > maxH) {
          height = maxH;
          width = height * widget.aspectRatio;
        }

        final displayWidth = math.min(width * 0.52, 128.0);
        final phase = _idle?.value ?? 0;
        final floatY = widget.enableIdleMotion ? math.sin(phase * math.pi * 2) * 1.2 : 0.0;

        return Center(
          child: Transform.translate(
            offset: Offset(0, floatY),
            child: SizedBox(
              width: displayWidth,
              height: height * 0.88,
              child: Image.asset(
                heroPath,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => Image.asset(
                  VehicleArtworkPaths.fallbackHero,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
