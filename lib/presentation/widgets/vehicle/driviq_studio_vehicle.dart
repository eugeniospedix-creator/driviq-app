import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/vehicle_artwork_paths.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/vehicle_3d_view_state.dart';
import 'vehicle_fault_hotspot.dart';

/// Studio-framed vehicle — static PNG hero with optional drag, zoom, and fault hotspots.
class DriviqStudioVehicle extends StatefulWidget {
  const DriviqStudioVehicle({
    super.key,
    required this.vehicle,
    required this.height,
    this.highlightColor,
    this.emotionalHome = false,
    this.showLiveAtmosphere = true,
    this.interactive = false,
    this.faults = const [],
    this.highlightedFault,
    this.onFaultSelected,
  });

  final Vehicle vehicle;
  final double height;
  final Color? highlightColor;
  final bool emotionalHome;
  final bool showLiveAtmosphere;
  final bool interactive;
  final List<ComponentFault> faults;
  final ComponentFault? highlightedFault;
  final ValueChanged<ComponentFault>? onFaultSelected;

  @override
  State<DriviqStudioVehicle> createState() => _DriviqStudioVehicleState();
}

class _DriviqStudioVehicleState extends State<DriviqStudioVehicle> with SingleTickerProviderStateMixin {
  Vehicle3DViewState _viewState = const Vehicle3DViewState(yaw: 0, pitch: 0, zoom: 1);
  double _baseZoom = 1;
  late final AnimationController _settle;
  Animation<double>? _settleAnim;
  double _settleStartYaw = 0;
  double _settleStartPitch = 0;

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _settle.addListener(_onSettleTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final path in VehicleArtworkPaths.allHeroes) {
      precacheImage(AssetImage(path), context);
    }
  }

  @override
  void dispose() {
    _settle.removeListener(_onSettleTick);
    _settle.dispose();
    super.dispose();
  }

  void _onSettleTick() {
    final t = Curves.easeOutCubic.transform(_settleAnim?.value ?? 1);
    setState(() {
      _viewState = _viewState.copyWith(
        yaw: _settleStartYaw * (1 - t),
        pitch: _settleStartPitch * (1 - t),
      );
    });
  }

  void _onScaleStart(ScaleStartDetails _) {
    _settle.stop();
    _baseZoom = _viewState.zoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!widget.interactive) return;
    setState(() {
      _viewState = _viewState.copyWith(
        yaw: (_viewState.yaw + details.focalPointDelta.dx * 0.0035).clamp(-0.42, 0.42),
        pitch: (_viewState.pitch + details.focalPointDelta.dy * 0.0025).clamp(-0.28, 0.28),
        zoom: (_baseZoom * details.scale).clamp(Vehicle3DViewState.minZoom, Vehicle3DViewState.maxZoom),
      );
    });
  }

  void _onScaleEnd(ScaleEndDetails _) {
    if (!widget.interactive) return;
    _settleStartYaw = _viewState.yaw;
    _settleStartPitch = _viewState.pitch;
    _settleAnim = CurvedAnimation(parent: _settle, curve: Curves.easeOutCubic);
    _settle.forward(from: 0);
  }

  Matrix4 _vehicleTransform(Size size) {
    final yawRad = _viewState.yaw * math.pi;
    final pitchRad = _viewState.pitch * math.pi;
    final lift = _viewState.pitch * size.height * 0.06;

    return Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..translateByDouble(0, lift, 0, 1)
      ..rotateY(yawRad)
      ..rotateX(pitchRad * 0.35)
      ..scaleByDouble(_viewState.zoom, _viewState.zoom, 1, 1);
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  final vehicleLayer = Transform(
                    alignment: Alignment.center,
                    transform: _vehicleTransform(size),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(
                          assetPath,
                          width: size.width,
                          height: size.height,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          gaplessPlayback: true,
                          errorBuilder: (_, _, _) => Image.asset(
                            VehicleArtworkPaths.fallback,
                            width: size.width,
                            height: size.height,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            gaplessPlayback: true,
                          ),
                        ),
                        ...widget.faults.map((fault) {
                          final selected = widget.highlightedFault?.id == fault.id;
                          final dx = fault.anchor.x * size.width;
                          final dy = fault.anchor.y * size.height;
                          final hotspotSize = selected ? 38.0 : 28.0;
                          return Positioned(
                            left: dx - hotspotSize / 2,
                            top: dy - hotspotSize / 2,
                            child: VehicleFaultHotspot(
                              severity: fault.severity,
                              selected: selected,
                              interactive: widget.interactive,
                              onTap: () => widget.onFaultSelected?.call(fault),
                            ),
                          );
                        }),
                      ],
                    ),
                  );

                  if (!widget.interactive) return vehicleLayer;

                  return GestureDetector(
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    onScaleEnd: _onScaleEnd,
                    behavior: HitTestBehavior.opaque,
                    child: vehicleLayer,
                  );
                },
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
