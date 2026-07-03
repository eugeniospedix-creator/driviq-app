/// Local persistence for processed vehicle photo assets.
abstract interface class VehiclePhotoRepository {
  Future<String> saveProcessedPng({
    required String vehicleId,
    required List<int> pngBytes,
  });

  /// Copies the picked image into app storage unchanged.
  Future<String> saveOriginalFromPath({
    required String vehicleId,
    required String sourcePath,
  });

  Future<void> deleteIfExists(String? path);

  String processedPhotoPath(String vehicleId);

  Future<bool> fileExists(String path);
}
