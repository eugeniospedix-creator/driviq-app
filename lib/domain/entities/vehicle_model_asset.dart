import '../enums/vehicle_model_generation_status.dart';

/// Generated or pending 3D model assets for a user vehicle.
class VehicleModelAsset {
  const VehicleModelAsset({
    required this.vehicleId,
    required this.status,
    required this.updatedAt,
    this.glbPath,
    this.usdzPath,
    this.texturePath,
    this.statusMessage,
    this.progress = 0,
  });

  final String vehicleId;
  final VehicleModelGenerationStatus status;
  final String? glbPath;
  final String? usdzPath;
  final String? texturePath;
  final String? statusMessage;
  final double progress;
  final DateTime updatedAt;

  bool get hasMesh =>
      glbPath != null && glbPath!.isNotEmpty && status == VehicleModelGenerationStatus.ready;

  VehicleModelAsset copyWith({
    VehicleModelGenerationStatus? status,
    String? glbPath,
    String? usdzPath,
    String? texturePath,
    String? statusMessage,
    double? progress,
    DateTime? updatedAt,
  }) {
    return VehicleModelAsset(
      vehicleId: vehicleId,
      status: status ?? this.status,
      glbPath: glbPath ?? this.glbPath,
      usdzPath: usdzPath ?? this.usdzPath,
      texturePath: texturePath ?? this.texturePath,
      statusMessage: statusMessage ?? this.statusMessage,
      progress: progress ?? this.progress,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
