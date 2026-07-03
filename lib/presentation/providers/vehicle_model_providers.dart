import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/vehicle_model_asset.dart';
import '../../domain/entities/vehicle_photo_set.dart';
import '../../services/interfaces/vehicle_3d_reconstruction_service.dart';
import '../../services/interfaces/vehicle_model_generator.dart';
import '../../services/vehicle_3d/local_vehicle_3d_reconstruction_service.dart';
import '../../services/vehicle_3d/production_vehicle_model_generator.dart';
import 'repository_providers.dart';

final vehicle3DReconstructionServiceProvider = Provider<Vehicle3DReconstructionService>((ref) {
  final store = ref.watch(hiveStoreProvider);
  return LocalVehicle3DReconstructionService(store);
});

final vehicleModelGeneratorProvider = Provider<VehicleModelGenerator>((ref) {
  return ProductionVehicleModelGenerator(ref.watch(vehicle3DReconstructionServiceProvider));
});

final productionVehicleModelGeneratorProvider = Provider<ProductionVehicleModelGenerator>((ref) {
  return ProductionVehicleModelGenerator(ref.watch(vehicle3DReconstructionServiceProvider));
});

final vehiclePhotoSetProvider = FutureProvider.family<VehiclePhotoSet?, String>((ref, vehicleId) {
  return ref.watch(vehicle3DReconstructionServiceProvider).getPhotoSet(vehicleId);
});

final vehicleModelAssetProvider = FutureProvider.family<VehicleModelAsset, String>((ref, vehicleId) {
  return ref.watch(vehicle3DReconstructionServiceProvider).getModelAsset(vehicleId);
});

final vehicleModelAssetStreamProvider = StreamProvider.family<VehicleModelAsset, String>((ref, vehicleId) {
  return ref.watch(vehicle3DReconstructionServiceProvider).watchModelAsset(vehicleId);
});
