import 'package:flutter/material.dart';

import '../../../core/constants/vehicle_artwork_paths.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle.dart';
import 'vehicle_fault_hotspot.dart';
import 'vehicle_hero_viewport.dart';

/// Studio-framed vehicle — stable viewport, optional fault hotspots on diagnosis/report.
class DriviqStudioVehicle extends StatefulWidget {
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
  });

  final Vehicle vehicle;
  final double height;
  final Color? highlightColor;
  final bool showLiveAtmosphere;
  final bool interactive;
  final List<ComponentFault> faults;
  final ComponentFault? highlightedFault;
  final ValueChanged<ComponentFault>? onFaultSelected;

  @override
  State<DriviqStudioVehicle> createState() => _DriviqStudioVehicleState();
}

class _DriviqStudioVehicleState extends State<DriviqStudioVehicle> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final path in VehicleArtworkPaths.allHeroes) {
      precacheImage(AssetImage(path), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.highlightColor ?? DQ.cyan;
    final h = widget.height;
    final viewportHeight = h * 0.68;

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
          if (widget.showLiveAtmosphere)
            Positioned(
              top: h * 0.08,
              left: h * 0.04,
              right: h * 0.04,
              height: h * 0.45,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.1),
                    radius: 0.95,
                    colors: [accent.withValues(alpha: 0.06), Colors.transparent],
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: viewportHeight,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VehicleHeroViewport(
                    vehicle: widget.vehicle,
                    enableIdleMotion: true,
                  ),
                  if (widget.faults.isNotEmpty)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final size = Size(constraints.maxWidth, constraints.maxHeight);
                        return Stack(
                          clipBehavior: Clip.none,
                          children: widget.faults.map((fault) {
                            final selected = widget.highlightedFault?.id == fault.id;
                            final hotspotSize = selected ? 38.0 : 28.0;
                            return Positioned(
                              left: fault.anchor.x * size.width - hotspotSize / 2,
                              top: fault.anchor.y * size.height - hotspotSize / 2,
                              child: VehicleFaultHotspot(
                                severity: fault.severity,
                                selected: selected,
                                interactive: widget.interactive,
                                onTap: () => widget.onFaultSelected?.call(fault),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          if (widget.showLiveAtmosphere)
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
                      DQ.voidBlack.withValues(alpha: 0.50),
                      DQ.voidBlack.withValues(alpha: 0.92),
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
