/// Generic licensed body archetype — no real-world brands.
enum VehicleBodyArchetype {
  sedan,
  suv,
  hatchback;

  String get assetFolder => name;

  String get label => switch (this) {
        VehicleBodyArchetype.sedan => 'Sedan',
        VehicleBodyArchetype.suv => 'SUV',
        VehicleBodyArchetype.hatchback => 'Hatchback',
      };
}
