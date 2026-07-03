import '../../../domain/catalog/vehicle_catalog.dart';
import '../../../domain/entities/vehicle.dart';

/// Body archetype for the Home hero silhouette renderer.
enum HomeVehicleBodyType {
  sportSedan,
  evSedan,
  compactSedan,
  executiveSedan,
}

abstract final class HomeVehicleBodyResolver {
  static HomeVehicleBodyType resolve(Vehicle vehicle) {
    final make = vehicle.make.toLowerCase();
    final model = vehicle.model.toLowerCase();

    if (make.contains('tesla') || make.contains('rivian') || make.contains('lucid')) {
      return HomeVehicleBodyType.evSedan;
    }
    if (make.contains('bmw')) return HomeVehicleBodyType.sportSedan;
    if (make.contains('toyota')) return HomeVehicleBodyType.compactSedan;
    if (make.contains('audi')) {
      if (model.contains('a4') || model.contains('a6') || model.contains('a8')) {
        return HomeVehicleBodyType.executiveSedan;
      }
      return HomeVehicleBodyType.compactSedan;
    }

    final catalog = VehicleCatalog.byAssetKey(vehicle.modelAssetKey);
    return switch (catalog?.silhouetteVariant) {
      'ev_sedan' => HomeVehicleBodyType.evSedan,
      'executive_sedan' => HomeVehicleBodyType.executiveSedan,
      'compact_sedan' => HomeVehicleBodyType.compactSedan,
      'sport_sedan' => HomeVehicleBodyType.sportSedan,
      _ => _fromAssetKey(vehicle.modelAssetKey),
    };
  }

  static HomeVehicleBodyType _fromAssetKey(String key) => switch (key) {
        'tesla_model_3' => HomeVehicleBodyType.evSedan,
        'bmw_m340i' || 'bmw_m3' => HomeVehicleBodyType.sportSedan,
        'audi_a4' => HomeVehicleBodyType.executiveSedan,
        'audi_a3' || 'toyota_corolla' => HomeVehicleBodyType.compactSedan,
        _ => HomeVehicleBodyType.sportSedan,
      };
}
