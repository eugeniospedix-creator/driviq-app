import '../../../domain/catalog/vehicle_catalog.dart';
import '../../../domain/entities/vehicle.dart';

/// Synchronous artwork paths for bundled vehicle hero images.
abstract final class VehicleArtworkPaths {
  static const _root = 'assets/vehicles/artwork';

  static const fallback = '$_root/sport_sedan/exterior.png';

  static const sportSedan = '$_root/sport_sedan/exterior.png';
  static const evSedan = '$_root/ev_sedan/exterior.png';
  static const compactSedan = '$_root/compact_sedan/exterior.png';
  static const executiveSedan = '$_root/executive_sedan/exterior.png';

  static const allHeroes = [sportSedan, evSedan, compactSedan, executiveSedan];

  /// Resolves the hero PNG for a vehicle — sync, no I/O.
  static String heroFor(Vehicle vehicle) {
    final make = vehicle.make.toLowerCase();
    final model = vehicle.model.toLowerCase();

    if (make.contains('tesla') || make.contains('rivian') || make.contains('lucid')) {
      return evSedan;
    }
    if (make.contains('bmw')) {
      return sportSedan;
    }
    if (make.contains('toyota')) {
      return compactSedan;
    }
    if (make.contains('audi')) {
      if (model.contains('a4') || model.contains('a6') || model.contains('a8')) {
        return executiveSedan;
      }
      return compactSedan;
    }

    final catalog = VehicleCatalog.byAssetKey(vehicle.modelAssetKey);
    final variant = catalog?.silhouetteVariant;
    return switch (variant) {
      'ev_sedan' => evSedan,
      'executive_sedan' => executiveSedan,
      'compact_sedan' => compactSedan,
      'sport_sedan' => sportSedan,
      _ => _fromAssetKey(vehicle.modelAssetKey),
    };
  }

  static String _fromAssetKey(String key) => switch (key) {
        'tesla_model_3' => evSedan,
        'bmw_m340i' => sportSedan,
        'bmw_m3' => sportSedan,
        'audi_a4' => executiveSedan,
        'audi_a3' => compactSedan,
        'toyota_corolla' => compactSedan,
        _ => fallback,
      };
}
