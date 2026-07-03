import 'vehicle_photo_bounds.dart';

/// Output of [VehiclePhotoProcessor] — transparent PNG ready for studio display.
class VehiclePhotoProcessResult {
  const VehiclePhotoProcessResult({
    required this.localPath,
    required this.confidence,
    this.bounds,
    required this.processedAt,
  });

  /// Absolute path to the processed PNG on device storage.
  final String localPath;

  /// Detection confidence 0–1 (mock returns ~0.72 until real AI is wired).
  final double confidence;

  final VehiclePhotoBounds? bounds;
  final DateTime processedAt;
}
