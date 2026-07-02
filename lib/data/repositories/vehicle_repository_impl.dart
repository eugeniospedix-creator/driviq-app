import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/local/hive_local_store.dart';
import '../models/vehicle_model.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._store);

  final HiveLocalStore _store;

  @override
  Future<void> delete(String id) async {
    await _store.vehicles.delete(id);
  }

  @override
  Future<List<Vehicle>> getAll() async {
    return _store.vehicles.values
        .map((v) => VehicleModel.fromJson(Map<dynamic, dynamic>.from(v as Map)).toEntity())
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Vehicle?> getById(String id) async {
    final raw = _store.vehicles.get(id);
    if (raw == null) return null;
    return VehicleModel.fromJson(Map<dynamic, dynamic>.from(raw as Map)).toEntity();
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
    for (final vehicle in all) {
      final updated = vehicle.copyWith(
        isPrimary: vehicle.id == id,
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }
}
