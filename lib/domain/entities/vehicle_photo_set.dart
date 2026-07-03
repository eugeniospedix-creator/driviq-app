import '../enums/vehicle_photo_angle.dart';

/// Multi-angle photo collection for 3D reconstruction.
class VehiclePhotoSet {
  const VehiclePhotoSet({
    required this.vehicleId,
    required this.photosByAngle,
    required this.updatedAt,
  });

  final String vehicleId;
  final Map<VehiclePhotoAngle, String> photosByAngle;
  final DateTime updatedAt;

  bool get isComplete =>
      VehiclePhotoAngle.captureSequence.every((angle) => photosByAngle[angle]?.isNotEmpty == true);

  int get capturedCount => photosByAngle.values.where((p) => p.isNotEmpty).length;

  int get requiredCount => VehiclePhotoAngle.captureSequence.length;

  VehiclePhotoSet copyWith({
    Map<VehiclePhotoAngle, String>? photosByAngle,
    DateTime? updatedAt,
  }) {
    return VehiclePhotoSet(
      vehicleId: vehicleId,
      photosByAngle: photosByAngle ?? this.photosByAngle,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
