import 'package:flutter/material.dart';

import '../../../core/constants/vehicle_artwork_paths.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/vehicle.dart';

/// Home hero vehicle — static artwork, stable layout, no scroll-driven motion.
class HomeVehicleHero extends StatefulWidget {
  const HomeVehicleHero({
    super.key,
    required this.vehicle,
    required this.height,
    this.highlightColor,
  });

  final Vehicle vehicle;
  final double height;
  final Color? highlightColor;

  @override
  State<HomeVehicleHero> createState() => _HomeVehicleHeroState();
}

class _HomeVehicleHeroState extends State<HomeVehicleHero> {
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
    final carHeight = h * 0.66;
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
                colors: [DQ.graphite2, DQ.voidBlack, DQ.voidBlack],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            top: h * 0.06,
            left: -h * 0.1,
            right: -h * 0.1,
            height: h * 0.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [
                    accent.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: h * 0.08,
            right: h * 0.08,
            bottom: h * 0.26,
            child: Container(
              height: h * 0.04,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.02),
            child: SizedBox(
              height: carHeight,
              width: double.infinity,
              child: _HeroImage(assetPath: assetPath),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: h * 0.32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    DQ.voidBlack.withValues(alpha: 0.55),
                    DQ.voidBlack.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
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
    );
  }
}
