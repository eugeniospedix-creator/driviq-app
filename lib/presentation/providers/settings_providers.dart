import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/enums/settings_key.dart';
import '../../domain/extensions/app_settings_scan.dart';
import 'repository_providers.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => ref.watch(settingsRepositoryProvider).get();

  Future<void> apply(AppSettings settings) async {
    final previous = state.value ?? const AppSettings();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).save(settings);
      return settings;
    });
    if (state.hasError) {
      state = AsyncData(previous);
    }
  }

  Future<void> toggle(SettingsKey key) async {
    final current = state.value ?? const AppSettings();
    await apply(current.toggle(key));
  }
}

final canRunScanProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return settings?.canRunScan() ?? false;
});
