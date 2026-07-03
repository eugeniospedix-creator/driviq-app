import 'package:flutter/material.dart';

import '../../domain/entities/component_fault.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_3d_metadata.dart';
import '../../domain/entities/vehicle_3d_view_state.dart';
import '../../domain/enums/vehicle_view_mode.dart';
import '../interfaces/vehicle_renderer.dart';
import 'glb_vehicle_renderer.dart';
import 'layered_artwork_vehicle_renderer.dart';
import 'vehicle_artwork_resolver.dart';
import 'vehicle_asset_pipeline.dart';

/// Rendering pipeline priority:
/// 1. Licensed GLB (when bundled)
/// 2. Layered pre-rendered artwork + live studio compositing
class CompositeVehicleRenderer implements VehicleRenderer {
  CompositeVehicleRenderer(this._pipeline)
      : _glb = GlbVehicleRenderer(),
        _artwork = LayeredArtworkVehicleRenderer(VehicleArtworkResolver()),
        _resolver = VehicleArtworkResolver();

  final VehicleAssetPipeline _pipeline;
  final GlbVehicleRenderer _glb;
  final LayeredArtworkVehicleRenderer _artwork;
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
    return FutureBuilder<_RenderMode>(
      future: _resolveMode(vehicle: vehicle, metadata: metadata),
      builder: (context, snapshot) {
        final mode = snapshot.data ?? _RenderMode.artwork;
        final renderer = switch (mode) {
          _RenderMode.glb => _glb,
          _RenderMode.artwork => _artwork,
        };

        return renderer.build(
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
        );
      },
    );
  }

  Future<_RenderMode> _resolveMode({
    required Vehicle vehicle,
    required Vehicle3DMetadata metadata,
  }) async {
    if (await _pipeline.hasBundledGlb(metadata.glbAssetPath)) {
      return _RenderMode.glb;
    }
    if (await _resolver.hasArtwork(vehicle: vehicle, metadata: metadata)) {
      return _RenderMode.artwork;
    }
    return _RenderMode.artwork;
  }
}

enum _RenderMode { glb, artwork }
