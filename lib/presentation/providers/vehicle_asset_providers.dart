import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/vehicle_asset_repository_impl.dart';
import '../../domain/entities/resolved_vehicle_asset_pack.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_asset_catalog.dart';
import '../../domain/repositories/vehicle_asset_repository.dart';

final vehicleAssetRepositoryProvider = Provider<VehicleAssetRepository>((ref) {
  return BundledVehicleAssetRepository();
});

final vehicleAssetCatalogProvider = FutureProvider<VehicleAssetCatalog>((ref) async {
  return ref.watch(vehicleAssetRepositoryProvider).loadCatalog();
});

final resolvedVehicleAssetProvider = FutureProvider.family<ResolvedVehicleAssetPack, Vehicle>((ref, vehicle) {
  final repo = ref.watch(vehicleAssetRepositoryProvider);
  return repo.resolveForVehicle(
    make: vehicle.make,
    model: vehicle.model,
    year: vehicle.year,
    modelAssetKey: vehicle.modelAssetKey,
  );
});
