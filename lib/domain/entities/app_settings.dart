class AppSettings {
  const AppSettings({
    this.microphoneEnabled = true,
    this.motionSensorsEnabled = true,
    this.privacyMode = true,
    this.safeDrivingMode = true,
    this.cloudAiEnabled = false,
    this.offlineAiEnabled = true,
    this.obdEnabled = false,
    this.arPreviewEnabled = false,
  });

  final bool microphoneEnabled;
  final bool motionSensorsEnabled;
  final bool privacyMode;
  final bool safeDrivingMode;
  final bool cloudAiEnabled;
  final bool offlineAiEnabled;
  final bool obdEnabled;
  final bool arPreviewEnabled;

  AppSettings copyWith({
    bool? microphoneEnabled,
    bool? motionSensorsEnabled,
    bool? privacyMode,
    bool? safeDrivingMode,
    bool? cloudAiEnabled,
    bool? offlineAiEnabled,
    bool? obdEnabled,
    bool? arPreviewEnabled,
  }) {
    return AppSettings(
      microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled,
      motionSensorsEnabled: motionSensorsEnabled ?? this.motionSensorsEnabled,
      privacyMode: privacyMode ?? this.privacyMode,
      safeDrivingMode: safeDrivingMode ?? this.safeDrivingMode,
      cloudAiEnabled: cloudAiEnabled ?? this.cloudAiEnabled,
      offlineAiEnabled: offlineAiEnabled ?? this.offlineAiEnabled,
      obdEnabled: obdEnabled ?? this.obdEnabled,
      arPreviewEnabled: arPreviewEnabled ?? this.arPreviewEnabled,
    );
  }
}
