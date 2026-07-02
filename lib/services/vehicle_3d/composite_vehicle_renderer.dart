import 'package:flutter/material.dart';

import '../../domain/entities/component_fault.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_3d_metadata.dart';
import '../../domain/entities/vehicle_3d_view_state.dart';
import '../../domain/enums/vehicle_view_mode.dart';
import '../interfaces/vehicle_renderer.dart';
import 'glb_vehicle_renderer.dart';
import 'premium_staging_3d_renderer.dart';
import 'vehicle_asset_pipeline.dart';

/// Selects GLB renderer when asset is bundled; otherwise premium staging twin.
class CompositeVehicleRenderer implements VehicleRenderer {
  CompositeVehicleRenderer(this._pipeline)
      : _glb = GlbVehicleRenderer(),
        _staging = PremiumStaging3DRenderer();

  final VehicleAssetPipeline _pipeline;
  final GlbVehicleRenderer _glb;
  final PremiumStaging3DRenderer _staging;

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
    return FutureBuilder<bool>(
      future: _pipeline.hasBundledGlb(metadata.glbAssetPath),
      builder: (context, snapshot) {
        final useGlb = snapshot.data == true;
        final renderer = useGlb ? _glb : _staging;
        return Stack(
          fit: StackFit.expand,
          children: [
            renderer.build(
              vehicle: vehicle,
              viewMode: viewMode,
              viewState: viewState,
              metadata: metadata,
              scanning: scanning,
              interactive: interactive,
              highlightedFault: highlightedFault,
              onFaultSelected: onFaultSelected,
              faults: faults,
              animationPhase: animationPhase,
            ),
            if (!useGlb && interactive)
              Positioned(
                left: 12,
                bottom: 8,
                child: Text(
                  'STAGING ASSET',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
