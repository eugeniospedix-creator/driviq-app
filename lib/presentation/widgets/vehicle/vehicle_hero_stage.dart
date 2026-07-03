import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle.dart';
import 'interactive_vehicle_viewer.dart';

/// Luxury studio stage wrapping the vehicle viewer — vignette, glow, depth.
class VehicleHeroStage extends StatefulWidget {
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

  @override
  State<VehicleHeroStage> createState() => _VehicleHeroStageState();
}

class _VehicleHeroStageState extends State<VehicleHeroStage> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.highlightColor ?? DQ.cyan;
    final h = widget.height ?? (widget.compact ? 180.0 : 320.0);

    return SizedBox(
      height: h,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AnimatedBuilder(
          animation: _shimmer,
          builder: (context, child) {
            final t = _shimmer.value * 2 * math.pi;
            return Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        DQ.graphite2,
                        DQ.voidBlack,
                        DQ.voidBlack,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: -40 + math.sin(t) * 6,
                  left: -20,
                  right: -20,
                  child: Container(
                    height: h * 0.65,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 0.85,
                        colors: [
                          accent.withValues(alpha: widget.scanning ? 0.18 : 0.11),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 24 + math.cos(t * 0.7) * 10,
                  top: h * 0.12,
                  child: Container(
                    width: 120,
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                child!,
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.05,
                        colors: [
                          Colors.transparent,
                          DQ.voidBlack.withValues(alpha: widget.compact ? 0.35 : 0.5),
                        ],
                        stops: const [0.62, 1.0],
                      ),
                    ),
                  ),
                ),
                if (!widget.compact)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: h * 0.35,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            DQ.voidBlack.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          child: RepaintBoundary(
            child: InteractiveVehicleViewer(
              vehicle: widget.vehicle,
              height: h,
              scanning: widget.scanning,
              interactive: widget.interactive,
              showGlow: widget.showGlow,
              faults: widget.faults,
            ),
          ),
        ),
      ),
    );
  }
}
