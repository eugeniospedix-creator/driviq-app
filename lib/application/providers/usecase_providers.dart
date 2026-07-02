import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/usecases/run_scan_usecase.dart';
import '../../application/usecases/save_vehicle_profile_usecase.dart';
import '../../application/usecases/set_primary_vehicle_usecase.dart';
import '../../presentation/providers/repository_providers.dart';

final saveVehicleProfileUseCaseProvider = Provider<SaveVehicleProfileUseCase>((ref) {
  return SaveVehicleProfileUseCase(ref.watch(vehicleRepositoryProvider));
});

final setPrimaryVehicleUseCaseProvider = Provider<SetPrimaryVehicleUseCase>((ref) {
  return SetPrimaryVehicleUseCase(ref.watch(vehicleRepositoryProvider));
});

final runScanUseCaseProvider = Provider<RunScanUseCase>((ref) {
  return RunScanUseCase(
    ai: ref.watch(aiDiagnosisServiceProvider),
    audio: ref.watch(audioAnalysisServiceProvider),
    diagnosis: ref.watch(diagnosisRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
  );
});
