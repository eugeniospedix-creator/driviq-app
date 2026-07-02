import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/local/hive_local_store.dart';
import '../models/vehicle_model.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._store);

  final HiveLocalStore _store;

  Vehicle? _parseVehicle(dynamic raw) {
    if (raw is! Map) return null;
    try {
      return VehicleModel.fromJson(Map<dynamic, dynamic>.from(raw)).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String id) async {
    await _store.vehicles.delete(id);
  }

  @override
  Future<List<Vehicle>> getAll() async {
    final vehicles = <Vehicle>[];
    for (final raw in _store.vehicles.values) {
      final vehicle = _parseVehicle(raw);
      if (vehicle != null) vehicles.add(vehicle);
    }
    vehicles.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return vehicles;
  }

  @override
  Future<Vehicle?> getById(String id) async {
    return _parseVehicle(_store.vehicles.get(id));
  }

  @override
  Future<Vehicle?> getPrimary() async {
    final all = await getAll();
    if (all.isEmpty) return null;
    return all.firstWhere((v) => v.isPrimary, orElse: () => all.first);
  }

  @override
  Future<void> save(Vehicle vehicle) async {
    await _store.vehicles.put(vehicle.id, VehicleModel.fromEntity(vehicle).toJson());
  }

  @override
  Future<void> setPrimary(String id) async {
    final all = await getAll();
    final now = DateTime.now();
    for (final vehicle in all) {
      final shouldBePrimary = vehicle.id == id;
      if (vehicle.isPrimary == shouldBePrimary) continue;
      await save(vehicle.copyWith(isPrimary: shouldBePrimary, updatedAt: now));
    }
  }
}
