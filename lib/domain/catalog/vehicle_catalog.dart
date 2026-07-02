import '../../domain/entities/vehicle_catalog_entry.dart';

/// Canonical vehicle catalog — domain knowledge mapping make/model to 3D assets.
abstract final class VehicleCatalog {
  static const genericSedan = VehicleCatalogEntry(
    assetKey: 'generic_sedan',
    make: 'Generic',
    model: 'Sedan',
    defaultYear: 2024,
    silhouetteVariant: 'sport_sedan',
  );

  static const bmwM340i = VehicleCatalogEntry(
    assetKey: 'bmw_m340i',
    make: 'BMW',
    model: 'M340i xDrive',
    defaultYear: 2021,
    glbAssetPath: 'assets/models/bmw/m340i.glb',
    silhouetteVariant: 'sport_sedan',
  );

  static const audiA3 = VehicleCatalogEntry(
    assetKey: 'audi_a3',
    make: 'Audi',
    model: 'A3 2.0 TDI',
    defaultYear: 2019,
    glbAssetPath: 'assets/models/audi/a3.glb',
    silhouetteVariant: 'compact_sedan',
  );

  static const teslaModel3 = VehicleCatalogEntry(
    assetKey: 'tesla_model_3',
    make: 'Tesla',
    model: 'Model 3',
    defaultYear: 2023,
    glbAssetPath: 'assets/models/tesla/model_3.glb',
    silhouetteVariant: 'ev_sedan',
  );

  static const bmwM3 = VehicleCatalogEntry(
    assetKey: 'bmw_m3',
    make: 'BMW',
    model: 'M3',
    defaultYear: 2024,
    glbAssetPath: 'assets/models/bmw/m3.glb',
    silhouetteVariant: 'sport_sedan',
  );

  static const audiA4 = VehicleCatalogEntry(
    assetKey: 'audi_a4',
    make: 'Audi',
    model: 'A4',
    defaultYear: 2022,
    glbAssetPath: 'assets/models/audi/a4.glb',
    silhouetteVariant: 'executive_sedan',
  );

  static const toyotaCorolla = VehicleCatalogEntry(
    assetKey: 'toyota_corolla',
    make: 'Toyota',
    model: 'Corolla',
    defaultYear: 2022,
    glbAssetPath: 'assets/models/toyota/corolla.glb',
    silhouetteVariant: 'compact_sedan',
  );

  static final entries = [
    bmwM340i,
    audiA3,
    teslaModel3,
    bmwM3,
    audiA4,
    toyotaCorolla,
  ];

  static VehicleCatalogEntry resolveOrDefault(String make, String model) {
    return resolve(make, model) ?? genericSedan;
  }

  static VehicleCatalogEntry? resolve(String make, String model) {
    final normalizedMake = make.trim().toLowerCase();
    final normalizedModel = model.trim().toLowerCase();
    for (final entry in entries) {
      if (entry.make.toLowerCase() == normalizedMake &&
          entry.model.toLowerCase() == normalizedModel) {
        return entry;
      }
    }
    for (final entry in entries) {
      if (normalizedMake.contains(entry.make.toLowerCase()) &&
          normalizedModel.contains(entry.model.split(' ').first.toLowerCase())) {
        return entry;
      }
    }
    return null;
  }

  static VehicleCatalogEntry? byAssetKey(String key) {
    if (key == genericSedan.assetKey) return genericSedan;
    for (final entry in entries) {
      if (entry.assetKey == key) return entry;
    }
    return null;
  }
}
