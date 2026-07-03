import 'package:flutter/services.dart';

import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_3d_metadata.dart';
import '../../domain/entities/vehicle_artwork_spec.dart';
import '../../domain/enums/vehicle_view_mode.dart';

/// Resolves pre-rendered artwork paths from body type, make, and bundled assets.
class VehicleArtworkResolver {
  static const _artworkRoot = 'assets/vehicles/artwork';

  static const _fallbackBody = 'sport_sedan';

  /// Maps catalog body types to artwork folders.
  static const _knownBodies = {
    'sport_sedan',
    'ev_sedan',
    'compact_sedan',
    'executive_sedan',
  };

  Future<VehicleArtworkSpec> resolve({
    required Vehicle vehicle,
    required Vehicle3DMetadata metadata,
  }) async {
    final bodyType = _effectiveBodyType(vehicle, metadata);
    final hero = await _firstAvailable([
      '$_artworkRoot/$bodyType/exterior.png',
      '$_artworkRoot/$_fallbackBody/exterior.png',
    ]);

    final engine = await _optional('$_artworkRoot/$bodyType/engine.png');
    final interior = await _optional('$_artworkRoot/$bodyType/interior.png');
    final suspension = await _optional('$_artworkRoot/$bodyType/suspension.png');

    return VehicleArtworkSpec(
      bodyType: bodyType,
      heroAssetPath: hero,
      engineAssetPath: engine,
      interiorAssetPath: interior,
      suspensionAssetPath: suspension,
    );
  }

  Future<bool> hasArtwork({
    required Vehicle vehicle,
    required Vehicle3DMetadata metadata,
  }) async {
    final bodyType = _effectiveBodyType(vehicle, metadata);
    return await _assetExists('$_artworkRoot/$bodyType/exterior.png') ||
        await _assetExists('$_artworkRoot/$_fallbackBody/exterior.png');
  }

  String _effectiveBodyType(Vehicle vehicle, Vehicle3DMetadata metadata) {
    final make = vehicle.make.toLowerCase();
    if (make.contains('tesla') || make.contains('rivian') || make.contains('lucid')) {
      return 'ev_sedan';
    }

    final body = metadata.bodyType;
    if (_knownBodies.contains(body)) return body;
    return _fallbackBody;
  }

  Future<String> _firstAvailable(List<String> candidates) async {
    for (final path in candidates) {
      if (await _assetExists(path)) return path;
    }
    return candidates.last;
  }

  Future<String?> _optional(String path) async {
    if (await _assetExists(path)) return path;
    return null;
  }

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// View-mode color grade when alternate artwork is not bundled.
  static ViewModeGrade gradeFor(VehicleViewMode mode) => switch (mode) {
        VehicleViewMode.engine => const ViewModeGrade(
            zoom: 1.12,
            offsetY: -0.04,
            warmth: 0.08,
          ),
        VehicleViewMode.interior || VehicleViewMode.dashboard => const ViewModeGrade(
            zoom: 1.06,
            offsetY: -0.02,
            brightness: -0.06,
          ),
        VehicleViewMode.suspension => const ViewModeGrade(
            zoom: 1.08,
            offsetY: 0.06,
            brightness: -0.04,
          ),
        _ => ViewModeGrade.none,
      };
}

/// Compositor adjustments when reusing the hero exterior for a view mode.
class ViewModeGrade {
  const ViewModeGrade({
    this.zoom = 1.0,
    this.offsetY = 0.0,
    this.brightness = 0.0,
    this.warmth = 0.0,
  });

  static const none = ViewModeGrade();

  final double zoom;
  final double offsetY;
  final double brightness;
  final double warmth;
}
