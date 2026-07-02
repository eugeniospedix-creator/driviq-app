import '../../domain/errors/app_exception.dart';
import '../../domain/repositories/vehicle_repository.dart';

class SetPrimaryVehicleUseCase {
  SetPrimaryVehicleUseCase(this._vehicles);

  final VehicleRepository _vehicles;

  Future<void> execute(String vehicleId) async {
    try {
      await _vehicles.setPrimary(vehicleId);
    } catch (_) {
      throw const PersistenceException('Could not update primary vehicle.');
    }
  }
}
