import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_settings.dart';
import 'repository_providers.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => ref.watch(settingsRepositoryProvider).get();

  Future<void> apply(AppSettings settings) async {
    state = const AsyncLoading();
    await ref.read(settingsRepositoryProvider).save(settings);
    state = AsyncData(settings);
  }

  Future<void> toggle(String key) async {
    final current = state.value ?? const AppSettings();
    final updated = switch (key) {
      'microphone' => current.copyWith(microphoneEnabled: !current.microphoneEnabled),
      'motion' => current.copyWith(motionSensorsEnabled: !current.motionSensorsEnabled),
      'privacy' => current.copyWith(privacyMode: !current.privacyMode),
      'safeDriving' => current.copyWith(safeDrivingMode: !current.safeDrivingMode),
      'cloudAi' => current.copyWith(cloudAiEnabled: !current.cloudAiEnabled),
      'offlineAi' => current.copyWith(offlineAiEnabled: !current.offlineAiEnabled),
      'obd' => current.copyWith(obdEnabled: !current.obdEnabled),
      'ar' => current.copyWith(arPreviewEnabled: !current.arPreviewEnabled),
      _ => current,
    };
    await apply(updated);
  }
}
