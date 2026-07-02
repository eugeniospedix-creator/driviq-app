enum ScanSource {
  microphone,
  accelerometer,
  gyroscope,
  obd,
  combined,
  cloudAi,
  offlineAi;

  String get label => switch (this) {
        ScanSource.microphone => 'Acoustic',
        ScanSource.accelerometer => 'Vibration',
        ScanSource.gyroscope => 'Motion',
        ScanSource.obd => 'OBD-II',
        ScanSource.combined => 'Multi-sensor',
        ScanSource.cloudAi => 'Cloud AI',
        ScanSource.offlineAi => 'On-device AI',
      };
}
