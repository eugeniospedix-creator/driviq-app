/// Output of a future photo-to-3D generation job.
class VehicleModelGenerationResult {
  const VehicleModelGenerationResult({
    this.glbPath,
    this.usdzPath,
    this.texturePath,
  });

  final String? glbPath;
  final String? usdzPath;
  final String? texturePath;

  bool get hasModel => glbPath != null || usdzPath != null;
}
