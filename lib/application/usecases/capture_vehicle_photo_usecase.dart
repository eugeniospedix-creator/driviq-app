import '../../domain/entities/vehicle.dart';
import '../../domain/errors/app_exception.dart';
import '../../domain/repositories/vehicle_photo_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';

class CaptureVehiclePhotoInput {
  const CaptureVehiclePhotoInput({
    required this.vehicleId,
    required this.sourceImagePath,
  });

  final String vehicleId;
  final String sourceImagePath;
}

/// Saves the picked vehicle photo as-is — no crop, no forced processing.
class CaptureVehiclePhotoUseCase {
  CaptureVehiclePhotoUseCase({
    required VehiclePhotoRepository photos,
    required VehicleRepository vehicles,
  })  : _photos = photos,
        _vehicles = vehicles;

  final VehiclePhotoRepository _photos;
  final VehicleRepository _vehicles;

  Future<Vehicle> execute(CaptureVehiclePhotoInput input) async {
    final vehicle = await _vehicles.getById(input.vehicleId);
    if (vehicle == null) {
      throw const ValidationException('Vehicle not found.');
    }

    final photoPath = await _photos.saveOriginalFromPath(
      vehicleId: input.vehicleId,
      sourcePath: input.sourceImagePath,
    );

    await _photos.deleteIfExists(vehicle.photoPath);

    final updated = vehicle.copyWith(
      photoPath: photoPath,
      updatedAt: DateTime.now(),
    );
    await _vehicles.save(updated);
    return updated;
  }
}
