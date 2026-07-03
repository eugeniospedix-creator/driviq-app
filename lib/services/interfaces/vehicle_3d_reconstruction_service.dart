import '../../domain/entities/vehicle_model_asset.dart';
import '../../domain/entities/vehicle_photo_set.dart';
import '../../domain/enums/vehicle_photo_angle.dart';

/// Photo → 3D reconstruction orchestration.
abstract interface class Vehicle3DReconstructionService {
  Future<VehiclePhotoSet?> getPhotoSet(String vehicleId);

  Future<VehiclePhotoSet> savePhoto({
    required String vehicleId,
    required VehiclePhotoAngle angle,
    required String localPath,
  });

  Future<VehicleModelAsset> getModelAsset(String vehicleId);

  /// Starts reconstruction when photo set is complete. Returns honest pending status until cloud/service is wired.
  Future<VehicleModelAsset> startReconstruction(String vehicleId);

  Stream<VehicleModelAsset> watchModelAsset(String vehicleId);
}
