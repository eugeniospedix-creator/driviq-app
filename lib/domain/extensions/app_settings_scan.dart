import '../entities/app_settings.dart';
import '../enums/settings_key.dart';

extension AppSettingsToggle on AppSettings {
  AppSettings toggle(SettingsKey key) => switch (key) {
        SettingsKey.microphone => copyWith(microphoneEnabled: !microphoneEnabled),
        SettingsKey.motion => copyWith(motionSensorsEnabled: !motionSensorsEnabled),
        SettingsKey.privacy => copyWith(privacyMode: !privacyMode),
        SettingsKey.safeDriving => copyWith(safeDrivingMode: !safeDrivingMode),
        SettingsKey.cloudAi => copyWith(cloudAiEnabled: !cloudAiEnabled),
        SettingsKey.offlineAi => copyWith(offlineAiEnabled: !offlineAiEnabled),
        SettingsKey.obd => copyWith(obdEnabled: !obdEnabled),
        SettingsKey.ar => copyWith(arPreviewEnabled: !arPreviewEnabled),
      };

  bool canRunScan() => microphoneEnabled && (offlineAiEnabled || cloudAiEnabled);
}
