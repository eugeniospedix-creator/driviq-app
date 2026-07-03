import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/usecases/capture_vehicle_photo_usecase.dart';
import '../../data/repositories/vehicle_photo_repository_impl.dart';
import '../../domain/repositories/vehicle_photo_repository.dart';
import '../../services/interfaces/vehicle_photo_processor.dart';
import '../../services/vehicle_photo/ai_vehicle_photo_processor.dart';
import 'repository_providers.dart';

final vehiclePhotoRepositoryProvider = Provider<VehiclePhotoRepository>((ref) {
  return VehiclePhotoRepositoryImpl();
});

final vehiclePhotoProcessorProvider = Provider<VehiclePhotoProcessor>((ref) {
  return AiVehiclePhotoProcessor(ref.watch(vehiclePhotoRepositoryProvider));
});

final captureVehiclePhotoUseCaseProvider = Provider<CaptureVehiclePhotoUseCase>((ref) {
  return CaptureVehiclePhotoUseCase(
    photos: ref.watch(vehiclePhotoRepositoryProvider),
    vehicles: ref.watch(vehicleRepositoryProvider),
  );
});
