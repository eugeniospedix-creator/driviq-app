/// Maps make/model to 3D asset keys for the vehicle rendering pipeline.
class VehicleCatalogEntry {
  const VehicleCatalogEntry({
    required this.assetKey,
    required this.make,
    required this.model,
    required this.defaultYear,
    this.glbAssetPath,
    this.silhouetteVariant,
  });

  final String assetKey;
  final String make;
  final String model;
  final int defaultYear;
  final String? glbAssetPath;
  final String? silhouetteVariant;
}
