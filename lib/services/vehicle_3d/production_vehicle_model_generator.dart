import '../../domain/entities/vehicle_model_generation_result.dart';
import '../../domain/entities/vehicle_photo_set.dart';
import '../../domain/enums/vehicle_photo_angle.dart';
import '../interfaces/vehicle_3d_reconstruction_service.dart';
import '../interfaces/vehicle_model_generator.dart';

/// Orchestrates multi-photo capture and reconstruction jobs.
class ProductionVehicleModelGenerator implements VehicleModelGenerator {
  ProductionVehicleModelGenerator(this._reconstruction);

  final Vehicle3DReconstructionService _reconstruction;

  @override
  Future<VehicleModelGenerationResult?> generate({
    required String vehicleId,
    required String photoPath,
  }) async {
    await _reconstruction.savePhoto(
      vehicleId: vehicleId,
      angle: VehiclePhotoAngle.threeQuarterFront,
      localPath: photoPath,
    );
    final asset = await _reconstruction.startReconstruction(vehicleId);
    if (!asset.hasMesh) return null;
    return VehicleModelGenerationResult(
      glbPath: asset.glbPath,
      usdzPath: asset.usdzPath,
      texturePath: asset.texturePath,
    );
  }

  Future<VehiclePhotoSet?> photoSet(String vehicleId) => _reconstruction.getPhotoSet(vehicleId);

  Future<VehiclePhotoSet> saveAnglePhoto({
    required String vehicleId,
    required VehiclePhotoAngle angle,
    required String localPath,
  }) =>
      _reconstruction.savePhoto(vehicleId: vehicleId, angle: angle, localPath: localPath);

  Future<void> submitForReconstruction(String vehicleId) async {
    await _reconstruction.startReconstruction(vehicleId);
  }
}
