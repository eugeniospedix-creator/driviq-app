import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/dq_tokens.dart';
import '../../core/visuals/fault_severity_colors.dart';
import '../../domain/entities/component_fault.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_3d_metadata.dart';
import '../../domain/entities/vehicle_3d_view_state.dart';
import '../../domain/enums/vehicle_view_mode.dart';
import '../interfaces/vehicle_renderer.dart';
import 'vehicle_artwork_resolver.dart';
import 'vehicle_studio_compositor.dart';

/// Artwork-first vehicle renderer — believable pre-rendered hero + live studio compositing.
class LayeredArtworkVehicleRenderer implements VehicleRenderer {
  LayeredArtworkVehicleRenderer(this._resolver);

  final VehicleArtworkResolver _resolver;

  @override
  Widget build({
    required Vehicle vehicle,
    required VehicleViewMode viewMode,
    required Vehicle3DViewState viewState,
    required Vehicle3DMetadata metadata,
    required bool scanning,
    required bool interactive,
    ComponentFault? highlightedFault,
    ValueChanged<ComponentFault>? onFaultSelected,
    List<ComponentFault> faults = const [],
    double animationPhase = 0,
  }) {
    return FutureBuilder(
      future: _resolver.resolve(vehicle: vehicle, metadata: metadata),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ColoredBox(
            color: DQ.voidBlack,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: DQ.cyan),
              ),
            ),
          );
        }

        final spec = snapshot.data!;
        final assetPath = spec.assetForView(viewMode);
        final accent = _brandAccent(vehicle.make);

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                VehicleStudioCompositor(
                  assetPath: assetPath,
                  viewMode: viewMode,
                  viewState: viewState,
                  scanning: scanning,
                  animationPhase: animationPhase,
                  accentColor: accent,
                ),
                ...faults.map((fault) {
                  final anchor = metadata.anchorFor(fault.componentId);
                  final pos = anchor?.forView(viewMode);
                  final projected = pos != null
                      ? _project(pos, viewState, size)
                      : Offset(fault.anchor.x * size.width, fault.anchor.y * size.height);
                  final selected = highlightedFault?.id == fault.id;
                  final color = FaultSeverityColors.accent(fault.severity);
                  return Positioned(
                    left: projected.dx - (selected ? 20 : 15),
                    top: projected.dy - (selected ? 20 : 15),
                    child: _FaultHotspot(
                      color: color,
                      selected: selected,
                      interactive: interactive,
                      onTap: () => onFaultSelected?.call(fault),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Color _brandAccent(String make) {
    final m = make.toLowerCase();
    if (m.contains('bmw')) return const Color(0xFF4DA3FF);
    if (m.contains('audi')) return const Color(0xFFB8C4D4);
    if (m.contains('tesla')) return const Color(0xFFE8EEF5);
    if (m.contains('toyota')) return const Color(0xFFEF4444);
    return DQ.cyan;
  }

  Offset _project(AnchorPosition3D pos, Vehicle3DViewState state, Size size) {
    final yaw = state.yaw * math.pi * 2;
    final x = pos.x - 0.5;
    final z = pos.z;
    final rotX = x * math.cos(yaw) + z * math.sin(yaw);
    final screenX = 0.5 + rotX * state.zoom * 0.9;
    final screenY = pos.y - state.pitch * 0.22;
    return Offset(screenX * size.width, screenY * size.height);
  }
}

class _FaultHotspot extends StatelessWidget {
  const _FaultHotspot({
    required this.color,
    required this.selected,
    required this.interactive,
    this.onTap,
  });

  final Color color;
  final bool selected;
  final bool interactive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: interactive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: selected ? 40 : 30,
        height: selected ? 40 : 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: selected ? 0.95 : 0.82),
          border: Border.all(color: Colors.white.withValues(alpha: 0.92), width: selected ? 2.5 : 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.75), blurRadius: selected ? 32 : 16),
          ],
        ),
      ),
    );
  }
}
