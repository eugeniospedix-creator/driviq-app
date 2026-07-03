import '../../domain/entities/vehicle_model_generation_result.dart';
import '../interfaces/vehicle_model_generator.dart';

/// Placeholder until photo-to-3D service is wired.
class StubVehicleModelGenerator implements VehicleModelGenerator {
  @override
  Future<VehicleModelGenerationResult?> generate({
    required String vehicleId,
    required String photoPath,
  }) async {
    return null;
  }
}
