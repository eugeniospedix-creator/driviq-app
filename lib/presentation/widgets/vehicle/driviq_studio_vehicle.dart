import 'package:flutter/material.dart';

import '../../../core/constants/vehicle_artwork_paths.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/vehicle.dart';

/// Studio-framed vehicle — static PNG hero, same paths as Home.
class DriviqStudioVehicle extends StatefulWidget {
  const DriviqStudioVehicle({
    super.key,
    required this.vehicle,
    required this.height,
    this.highlightColor,
    this.emotionalHome = false,
    this.showLiveAtmosphere = true,
  });

  final Vehicle vehicle;
  final double height;
  final Color? highlightColor;
  final bool emotionalHome;
  final bool showLiveAtmosphere;

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
    final carHeight = h * 0.65;
    final assetPath = VehicleArtworkPaths.heroFor(widget.vehicle);

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
                    colors: [
                      accent.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          Align(
            alignment: const Alignment(0, 0.02),
            child: SizedBox(
              height: carHeight,
              width: double.infinity,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => Image.asset(
                  VehicleArtworkPaths.fallback,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),
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
