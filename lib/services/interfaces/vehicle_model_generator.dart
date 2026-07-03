import '../../domain/entities/vehicle_model_generation_result.dart';

/// Future photo → 3D pipeline (GLB / USDZ from user vehicle photo).
abstract interface class VehicleModelGenerator {
  Future<VehicleModelGenerationResult?> generate({
    required String vehicleId,
    required String photoPath,
  });
}
