import '../../domain/entities/app_settings.dart';

class AppSettingsModel {
  const AppSettingsModel({
    required this.microphoneEnabled,
    required this.motionSensorsEnabled,
    required this.privacyMode,
    required this.safeDrivingMode,
    required this.cloudAiEnabled,
    required this.offlineAiEnabled,
    required this.obdEnabled,
    required this.arPreviewEnabled,
  });

  final bool microphoneEnabled;
  final bool motionSensorsEnabled;
  final bool privacyMode;
  final bool safeDrivingMode;
  final bool cloudAiEnabled;
  final bool offlineAiEnabled;
  final bool obdEnabled;
  final bool arPreviewEnabled;

  factory AppSettingsModel.fromEntity(AppSettings entity) => AppSettingsModel(
        microphoneEnabled: entity.microphoneEnabled,
        motionSensorsEnabled: entity.motionSensorsEnabled,
        privacyMode: entity.privacyMode,
        safeDrivingMode: entity.safeDrivingMode,
        cloudAiEnabled: entity.cloudAiEnabled,
        offlineAiEnabled: entity.offlineAiEnabled,
        obdEnabled: entity.obdEnabled,
        arPreviewEnabled: entity.arPreviewEnabled,
      );

  AppSettings toEntity() => AppSettings(
        microphoneEnabled: microphoneEnabled,
        motionSensorsEnabled: motionSensorsEnabled,
        privacyMode: privacyMode,
        safeDrivingMode: safeDrivingMode,
        cloudAiEnabled: cloudAiEnabled,
        offlineAiEnabled: offlineAiEnabled,
        obdEnabled: obdEnabled,
        arPreviewEnabled: arPreviewEnabled,
      );

  Map<String, dynamic> toJson() => {
        'microphoneEnabled': microphoneEnabled,
        'motionSensorsEnabled': motionSensorsEnabled,
        'privacyMode': privacyMode,
        'safeDrivingMode': safeDrivingMode,
        'cloudAiEnabled': cloudAiEnabled,
        'offlineAiEnabled': offlineAiEnabled,
        'obdEnabled': obdEnabled,
        'arPreviewEnabled': arPreviewEnabled,
      };

  factory AppSettingsModel.fromJson(Map<dynamic, dynamic> json) => AppSettingsModel(
        microphoneEnabled: json['microphoneEnabled'] as bool? ?? true,
        motionSensorsEnabled: json['motionSensorsEnabled'] as bool? ?? true,
        privacyMode: json['privacyMode'] as bool? ?? true,
        safeDrivingMode: json['safeDrivingMode'] as bool? ?? true,
        cloudAiEnabled: json['cloudAiEnabled'] as bool? ?? false,
        offlineAiEnabled: json['offlineAiEnabled'] as bool? ?? true,
        obdEnabled: json['obdEnabled'] as bool? ?? false,
        arPreviewEnabled: json['arPreviewEnabled'] as bool? ?? false,
      );
}
