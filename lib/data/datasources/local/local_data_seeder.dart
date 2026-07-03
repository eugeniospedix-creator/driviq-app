import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/repositories/diagnosis_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/repositories/vehicle_repository.dart';
import 'hive_local_store.dart';

class LocalDataSeeder {
  LocalDataSeeder({
    required this.store,
    required this.vehicles,
    required this.diagnosis,
    required this.settings,
  });

  final HiveLocalStore store;
  final VehicleRepository vehicles;
  final DiagnosisRepository diagnosis;
  final SettingsRepository settings;

  Future<void> seedIfNeeded() async {
    if (store.seedVersion >= AppConstants.seedVersion) return;

    await settings.save(const AppSettings());

    await store.setSeedVersion(AppConstants.seedVersion);
  }
}
