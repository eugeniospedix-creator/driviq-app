import 'vehicle_photo_bounds.dart';

/// Result of analyzing a source photo before segmentation.
class VehiclePhotoDetection {
  const VehiclePhotoDetection({
    required this.bounds,
    required this.confidence,
  });

  final VehiclePhotoBounds bounds;

  /// 0–1 — below ~0.55 triggers manual crop fallback.
  final double confidence;

  static const confidenceThreshold = 0.55;
}
