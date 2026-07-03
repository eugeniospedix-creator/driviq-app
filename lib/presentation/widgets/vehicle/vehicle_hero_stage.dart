import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle.dart';
import 'driviq_studio_vehicle.dart';

/// Luxury studio stage wrapping the vehicle viewer — static overlays only.
class VehicleHeroStage extends StatelessWidget {
  const VehicleHeroStage({
    super.key,
    required this.vehicle,
    this.height,
    this.faults = const [],
    this.scanning = false,
    this.interactive = false,
    this.showGlow = true,
    this.compact = false,
    this.highlightColor,
    this.borderRadius = 0,
    this.highlightedFault,
    this.onFaultSelected,
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
  final ComponentFault? highlightedFault;
  final ValueChanged<ComponentFault>? onFaultSelected;

  @override
  Widget build(BuildContext context) {
    final accent = highlightColor ?? DQ.cyan;
    final h = height ?? (compact ? 180.0 : 320.0);

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
              top: -20,
              left: -20,
              right: -20,
              child: Container(
                height: h * 0.65,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.85,
                    colors: [
                      accent.withValues(alpha: scanning ? 0.14 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            RepaintBoundary(
              child: DriviqStudioVehicle(
                vehicle: vehicle,
                height: h,
                highlightColor: highlightColor,
                showLiveAtmosphere: showGlow,
                interactive: interactive,
                faults: faults,
                highlightedFault: highlightedFault,
                onFaultSelected: onFaultSelected,
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
                      DQ.voidBlack.withValues(alpha: compact ? 0.12 : 0.20),
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
                      colors: [
                        Colors.transparent,
                        DQ.voidBlack.withValues(alpha: 0.75),
                      ],
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
