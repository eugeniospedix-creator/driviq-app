import '../../domain/entities/vehicle_photo_bounds.dart';
import '../../domain/entities/vehicle_photo_detection.dart';
import '../../domain/entities/vehicle_photo_process_result.dart';

/// Segments the user's car from a photo and produces a transparent PNG.
///
/// Future implementations: Apple Vision, Google ML Kit, cloud segmentation API.
abstract interface class VehiclePhotoProcessor {
  /// Detects the vehicle bounding box and confidence before cropping.
  Future<VehiclePhotoDetection> analyze({required String sourceImagePath});

  /// Crops, removes background, and writes a transparent PNG.
  Future<VehiclePhotoProcessResult> process({
    required String sourceImagePath,
    required String vehicleId,
    VehiclePhotoBounds? cropBounds,
  });
}
