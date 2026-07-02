import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/hive_local_store.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._store);

  final HiveLocalStore _store;
  static const _key = 'app';

  @override
  Future<AppSettings> get() async {
    final raw = _store.settings.get(_key);
    if (raw == null) return const AppSettings();
    return AppSettingsModel.fromJson(Map<dynamic, dynamic>.from(raw as Map)).toEntity();
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _store.settings.put(_key, AppSettingsModel.fromEntity(settings).toJson());
  }
}
