import '../../../domain/catalog/vehicle_body_resolver.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/enums/vehicle_body_archetype.dart';

/// Licensed Kenney CC0 vehicle asset paths.
abstract final class VehicleArtworkPaths {
  static const _kenneyRoot = 'assets/vehicles/kenney';

  static const sedanHero = '$_kenneyRoot/sedan/hero.png';
  static const suvHero = '$_kenneyRoot/suv/hero.png';
  static const hatchbackHero = '$_kenneyRoot/hatchback/hero.png';

  static const sedanGlb = '$_kenneyRoot/sedan/model.glb';
  static const suvGlb = '$_kenneyRoot/suv/model.glb';
  static const hatchbackGlb = '$_kenneyRoot/hatchback/model.glb';

  static const fallbackHero = sedanHero;
  static const fallbackGlb = sedanGlb;

  static const allHeroes = [sedanHero, suvHero, hatchbackHero, fallbackHero];
  static const allModels = [sedanGlb, suvGlb, hatchbackGlb, fallbackGlb];

  static String heroFor(Vehicle vehicle) => heroForArchetype(VehicleBodyResolver.resolve(vehicle));

  static String glbFor(Vehicle vehicle) => glbForArchetype(VehicleBodyResolver.resolve(vehicle));

  static String heroForArchetype(VehicleBodyArchetype archetype) => switch (archetype) {
        VehicleBodyArchetype.sedan => sedanHero,
        VehicleBodyArchetype.suv => suvHero,
        VehicleBodyArchetype.hatchback => hatchbackHero,
      };

  static String glbForArchetype(VehicleBodyArchetype archetype) => switch (archetype) {
        VehicleBodyArchetype.sedan => sedanGlb,
        VehicleBodyArchetype.suv => suvGlb,
        VehicleBodyArchetype.hatchback => hatchbackGlb,
      };
}
