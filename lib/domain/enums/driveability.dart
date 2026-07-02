enum Driveability {
  safe,
  caution,
  limited,
  doNotDrive;

  String get label => switch (this) {
        Driveability.safe => 'Safe to drive',
        Driveability.caution => 'Drive with caution',
        Driveability.limited => 'Limited driving',
        Driveability.doNotDrive => 'Do not drive',
      };

  String get explanation => switch (this) {
        Driveability.safe =>
          'No immediate risk detected. Schedule routine inspection as recommended.',
        Driveability.caution =>
          'Component degradation detected. Avoid aggressive driving and inspect soon.',
        Driveability.limited =>
          'Mechanical stress may worsen under load. Limit trips and seek inspection.',
        Driveability.doNotDrive =>
          'Continuing to drive may cause further damage or safety risk.',
      };
}
