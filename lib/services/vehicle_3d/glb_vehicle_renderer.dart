import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../domain/entities/component_fault.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_3d_metadata.dart';
import '../../domain/entities/vehicle_3d_view_state.dart';
import '../../domain/enums/vehicle_view_mode.dart';
import '../interfaces/vehicle_renderer.dart';

/// Renders licensed/bundled GLB assets when present in the asset bundle.
class GlbVehicleRenderer implements VehicleRenderer {
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
    final glb = metadata.glbAssetPath;
    if (glb == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ModelViewer(
        key: ValueKey('$glb-${viewMode.name}'),
        src: glb,
        alt: '${vehicle.displayName} 3D model',
        ar: false,
        autoRotate: scanning,
        cameraControls: interactive,
        disableZoom: !interactive,
        backgroundColor: const Color(0x00000000),
        interactionPrompt: InteractionPrompt.none,
      ),
    );
  }
}
