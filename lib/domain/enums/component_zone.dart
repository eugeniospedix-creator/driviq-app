enum ComponentZone {
  powertrain,
  wheelAssembly,
  frictionSystem,
  chassis,
  exhaust,
  electrical,
  climate,
  body;

  String get label => switch (this) {
        ComponentZone.powertrain => 'Powertrain',
        ComponentZone.wheelAssembly => 'Wheel Assembly',
        ComponentZone.frictionSystem => 'Friction System',
        ComponentZone.chassis => 'Chassis',
        ComponentZone.exhaust => 'Exhaust',
        ComponentZone.electrical => 'Electrical',
        ComponentZone.climate => 'Climate',
        ComponentZone.body => 'Body',
      };
}
