import '../../domain/entities/vehicle.dart';

/// Visual model for a user's vehicle — 2.5D photo studio or future generated GLB.
class VehicleStudioModel {
  const VehicleStudioModel({
    required this.vehicle,
    this.generatedGlbPath,
    this.generatedUsdzPath,
  });

  final Vehicle vehicle;
  final String? generatedGlbPath;
  final String? generatedUsdzPath;

  factory VehicleStudioModel.fromVehicle(
    Vehicle vehicle, {
    String? glbPath,
    String? usdzPath,
  }) {
    return VehicleStudioModel(
      vehicle: vehicle,
      generatedGlbPath: glbPath,
      generatedUsdzPath: usdzPath,
    );
  }

  String? get photoPath => vehicle.photoPath;

  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  bool get hasGeneratedMesh =>
      generatedGlbPath != null && generatedGlbPath!.isNotEmpty;

  /// True when no real 3D mesh exists — use premium 2.5D photo presentation.
  bool get usePhotoStudio25D => !hasGeneratedMesh;
}
