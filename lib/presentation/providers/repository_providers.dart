import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/hive_local_store.dart';
import '../../data/repositories/diagnosis_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../services/interfaces/diagnosis_services.dart';
import '../../services/interfaces/vehicle_renderer.dart';
import '../../services/local_diagnosis_service.dart';
import '../../services/vector_vehicle_renderer.dart';

final hiveStoreProvider = Provider<HiveLocalStore>((ref) {
  throw StateError('HiveLocalStore must be overridden at bootstrap.');
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(ref.watch(hiveStoreProvider));
});

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  return DiagnosisRepositoryImpl(ref.watch(hiveStoreProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(hiveStoreProvider));
});

final vehicleRendererProvider = Provider<VehicleRenderer>((ref) {
  return VectorVehicleRenderer();
});

final audioAnalysisServiceProvider = Provider<AudioAnalysisService>((ref) {
  final service = SimulatedAudioAnalysisService();
  ref.onDispose(service.dispose);
  return service;
});

final aiDiagnosisServiceProvider = Provider<AiDiagnosisService>((ref) {
  return LocalDiagnosisService(ref.watch(diagnosisRepositoryProvider));
});
