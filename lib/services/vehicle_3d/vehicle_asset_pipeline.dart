import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/catalog/vehicle_catalog.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_3d_metadata.dart';
import '../../domain/enums/vehicle_view_mode.dart';

/// Loads 3D metadata and resolves GLB asset paths for the vehicle pipeline.
class VehicleAssetPipeline {
  VehicleAssetPipeline();

  final _cache = <String, Vehicle3DMetadata>{};

  Future<Vehicle3DMetadata> resolve(Vehicle vehicle) async {
    final cached = _cache[vehicle.modelAssetKey];
    if (cached != null) return cached;

    final metadata = await _loadMetadata(vehicle.modelAssetKey);
    _cache[vehicle.modelAssetKey] = metadata;
    return metadata;
  }

  Future<Vehicle3DMetadata> _loadMetadata(String assetKey) async {
    final path = 'assets/vehicles/metadata/$assetKey.json';
    try {
      final raw = await rootBundle.loadString(path);
      return _parseMetadata(assetKey, jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      final fallback = await rootBundle.loadString('assets/vehicles/metadata/generic_sedan.json');
      return _parseMetadata(assetKey, jsonDecode(fallback) as Map<String, dynamic>);
    }
  }

  Vehicle3DMetadata _parseMetadata(String assetKey, Map<String, dynamic> json) {
    final catalog = VehicleCatalog.byAssetKey(assetKey);
    final anchorsJson = json['anchors'] as List<dynamic>? ?? [];
    final anchors = anchorsJson.map((a) {
      final map = a as Map<String, dynamic>;
      final componentId = map['componentId'] as String;
      final positionsRaw = map['positions'] as Map<String, dynamic>;
      final positions = <VehicleViewMode, AnchorPosition3D>{};
      for (final entry in positionsRaw.entries) {
        final mode = VehicleViewMode.values.where((m) => m.name == entry.key).firstOrNull;
        if (mode != null) {
          positions[mode] = AnchorPosition3D.fromJson(Map<String, dynamic>.from(entry.value as Map));
        }
      }
      return ComponentAnchor3D(componentId: componentId, positions: positions);
    }).toList();

    return Vehicle3DMetadata(
      assetKey: assetKey,
      bodyType: json['bodyType'] as String? ?? catalog?.silhouetteVariant ?? 'sport_sedan',
      glbAssetPath: json['glbAssetPath'] as String? ?? catalog?.glbAssetPath,
      stagingLabel: json['stagingLabel'] as String? ?? 'Digital Twin Preview',
      anchors: anchors,
    );
  }

  Future<bool> hasBundledGlb(String? path) async {
    if (path == null || path.isEmpty) return false;
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
