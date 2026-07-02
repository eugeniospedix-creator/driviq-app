import 'package:uuid/uuid.dart';

import '../../domain/catalog/vehicle_catalog.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/errors/app_exception.dart';
import '../../domain/repositories/vehicle_repository.dart';

class SaveVehicleProfileInput {
  const SaveVehicleProfileInput({
    required this.existingId,
    required this.make,
    required this.model,
    required this.year,
    this.isPrimary = true,
    this.createdAt,
  });

  final String? existingId;
  final String make;
  final String model;
  final int year;
  final bool isPrimary;
  final DateTime? createdAt;
}

class SaveVehicleProfileUseCase {
  SaveVehicleProfileUseCase(this._vehicles);

  final VehicleRepository _vehicles;

  static const _uuid = Uuid();

  Future<Vehicle> execute(SaveVehicleProfileInput input) async {
    final make = input.make.trim();
    final model = input.model.trim();
    if (make.isEmpty || model.isEmpty) {
      throw const ValidationException('Make and model are required.');
    }

    final catalog = VehicleCatalog.resolveOrDefault(make, model);
    final now = DateTime.now();

    final vehicle = Vehicle(
      id: input.existingId ?? _uuid.v4(),
      make: make,
      model: model,
      year: input.year,
      modelAssetKey: catalog.assetKey,
      isPrimary: input.isPrimary,
      createdAt: input.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await _vehicles.save(vehicle);
    } catch (_) {
      throw const PersistenceException('Could not save vehicle profile.');
    }

    return vehicle;
  }
}
