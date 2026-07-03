import '../enums/vehicle_view_mode.dart';

/// Resolved artwork paths for a vehicle presentation bundle.
class VehicleArtworkSpec {
  const VehicleArtworkSpec({
    required this.bodyType,
    required this.heroAssetPath,
    this.engineAssetPath,
    this.interiorAssetPath,
    this.suspensionAssetPath,
  });

  final String bodyType;
  final String heroAssetPath;
  final String? engineAssetPath;
  final String? interiorAssetPath;
  final String? suspensionAssetPath;

  String assetForView(VehicleViewMode mode) => switch (mode) {
        VehicleViewMode.engine => engineAssetPath ?? heroAssetPath,
        VehicleViewMode.interior || VehicleViewMode.dashboard => interiorAssetPath ?? heroAssetPath,
        VehicleViewMode.suspension => suspensionAssetPath ?? heroAssetPath,
        VehicleViewMode.exterior || VehicleViewMode.ar => heroAssetPath,
      };
}
