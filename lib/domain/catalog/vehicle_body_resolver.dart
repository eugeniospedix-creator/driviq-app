import '../catalog/vehicle_catalog.dart';
import '../entities/vehicle.dart';
import '../enums/vehicle_body_archetype.dart';

abstract final class VehicleBodyResolver {
  static VehicleBodyArchetype resolve(Vehicle vehicle) {
    final make = vehicle.make.toLowerCase();
    final model = vehicle.model.toLowerCase();

    if (model.contains('suv') || model.contains('x5') || model.contains('q5')) {
      return VehicleBodyArchetype.suv;
    }
    if (make.contains('tesla') || make.contains('rivian') || make.contains('lucid')) {
      return VehicleBodyArchetype.sedan;
    }
    if (make.contains('toyota') && model.contains('corolla')) {
      return VehicleBodyArchetype.hatchback;
    }
    if (make.contains('audi') && model.contains('a3')) {
      return VehicleBodyArchetype.hatchback;
    }

    final catalog = VehicleCatalog.byAssetKey(vehicle.modelAssetKey);
    return switch (catalog?.silhouetteVariant) {
      'compact_sedan' => VehicleBodyArchetype.hatchback,
      'ev_sedan' => VehicleBodyArchetype.sedan,
      'executive_sedan' => VehicleBodyArchetype.sedan,
      'sport_sedan' => VehicleBodyArchetype.sedan,
      _ => _fromAssetKey(vehicle.modelAssetKey),
    };
  }

  static VehicleBodyArchetype _fromAssetKey(String key) => switch (key) {
        'tesla_model_3' => VehicleBodyArchetype.sedan,
        'bmw_m340i' || 'bmw_m3' || 'audi_a4' => VehicleBodyArchetype.sedan,
        'audi_a3' || 'toyota_corolla' => VehicleBodyArchetype.hatchback,
        _ => VehicleBodyArchetype.sedan,
      };
}
