import 'package:flutter_test/flutter_test.dart';

import 'package:driviq/domain/catalog/vehicle_asset_resolver_logic.dart';
import 'package:driviq/domain/entities/vehicle_asset_catalog.dart';
import 'package:driviq/domain/enums/vehicle_asset_resolution_kind.dart';

void main() {
  final catalog = VehicleAssetCatalog(
    catalogVersion: 'test',
    studioProfileId: 'driviq_dark_studio_v1',
    universalPackId: '_fallback/universal',
    fallbackChains: {
      'sport_sedan': ['_fallback/sport_sedan', '_fallback/universal'],
      'ev_sedan': ['_fallback/ev_sedan', '_fallback/universal'],
      'compact_sedan': ['_fallback/compact_sedan', '_fallback/universal'],
    },
    entries: [
      const VehicleCatalogRecord(
        id: 'bmw.g20_m340i',
        make: 'BMW',
        model: 'M340i',
        modelAliases: ['M340i xDrive'],
        generation: 'G20',
        yearFrom: 2019,
        yearTo: 2025,
        bodyType: 'sport_sedan',
        fuelTypes: ['petrol'],
        packId: 'bmw/g20-m340i',
        matchPriority: 100,
      ),
      const VehicleCatalogRecord(
        id: 'tesla.model_3',
        make: 'Tesla',
        model: 'Model 3',
        modelAliases: ['Model 3 Performance'],
        generation: 'Highland',
        yearFrom: 2017,
        yearTo: null,
        bodyType: 'ev_sedan',
        fuelTypes: ['electric'],
        packId: 'tesla/model-3',
        matchPriority: 100,
      ),
    ],
  );

  test('resolves BMW M340i to exact pack', () {
    final match = VehicleAssetResolverLogic.matchCatalogEntry(
      catalog: catalog,
      make: 'BMW',
      model: 'M340i xDrive',
      year: 2021,
      modelAssetKey: 'bmw_m340i',
    );
    expect(match?.packId, 'bmw/g20-m340i');
    expect(match?.resolution, VehicleAssetResolutionKind.exact);
  });

  test('resolves Tesla Model 3 to exact pack', () {
    final match = VehicleAssetResolverLogic.matchCatalogEntry(
      catalog: catalog,
      make: 'Tesla',
      model: 'Model 3',
      year: 2023,
      modelAssetKey: 'tesla_model_3',
    );
    expect(match?.packId, 'tesla/model-3');
    expect(match?.bodyType, 'ev_sedan');
  });

  test('fallback chain returns body type pack', () {
    expect(
      VehicleAssetResolverLogic.resolveFallbackPackId(catalog, 'ev_sedan'),
      '_fallback/ev_sedan',
    );
  });
}
