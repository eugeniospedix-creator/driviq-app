import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/hive_local_store.dart';
import '../../data/repositories/diagnosis_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_3d_metadata.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../services/hybrid_audio_analysis_service.dart';
import '../../services/interfaces/diagnosis_services.dart';
import '../../services/interfaces/vehicle_renderer.dart';
import '../../services/local_diagnosis_service.dart';
import '../../services/microphone_permission_service.dart';
import '../../services/record_audio_analysis_service.dart';
import '../../services/signal_diagnosis_service.dart';
import '../../services/vehicle_3d/composite_vehicle_renderer.dart';
import '../../services/vehicle_3d/vehicle_asset_pipeline.dart';

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

final vehicleAssetPipelineProvider = Provider<VehicleAssetPipeline>((ref) {
  return VehicleAssetPipeline();
});

final vehicleMetadataProvider = FutureProvider.family<Vehicle3DMetadata, Vehicle>((ref, vehicle) {
  return ref.watch(vehicleAssetPipelineProvider).resolve(vehicle);
});

final vehicleRendererProvider = Provider<VehicleRenderer>((ref) {
  return CompositeVehicleRenderer(ref.watch(vehicleAssetPipelineProvider));
});

final microphonePermissionProvider = FutureProvider<bool>((ref) async {
  return ref.watch(microphonePermissionServiceProvider).isGranted;
});

final microphonePermissionServiceProvider = Provider<MicrophonePermissionService>((ref) {
  return MicrophonePermissionService();
});

final audioAnalysisServiceProvider = Provider<AudioAnalysisService>((ref) {
  final service = HybridAudioAnalysisService(
    real: RecordAudioAnalysisService(),
    simulated: SimulatedAudioAnalysisService(),
  );
  ref.onDispose(service.dispose);
  return service;
});

final aiDiagnosisServiceProvider = Provider<AiDiagnosisService>((ref) {
  return SignalDiagnosisService(ref.watch(diagnosisRepositoryProvider));
});
