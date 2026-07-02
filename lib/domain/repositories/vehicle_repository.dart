import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getAll();
  Future<Vehicle?> getById(String id);
  Future<Vehicle?> getPrimary();
  Future<void> save(Vehicle vehicle);
  Future<void> delete(String id);
  Future<void> setPrimary(String id);
}
