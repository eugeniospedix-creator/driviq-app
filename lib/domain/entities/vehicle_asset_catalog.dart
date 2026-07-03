class VehicleCatalogRecord {
  const VehicleCatalogRecord({
    required this.id,
    required this.make,
    required this.model,
    required this.modelAliases,
    required this.generation,
    required this.yearFrom,
    required this.yearTo,
    required this.bodyType,
    required this.fuelTypes,
    required this.packId,
    required this.matchPriority,
    this.status = 'active',
  });

  final String id;
  final String make;
  final String model;
  final List<String> modelAliases;
  final String? generation;
  final int? yearFrom;
  final int? yearTo;
  final String bodyType;
  final List<String> fuelTypes;
  final String packId;
  final int matchPriority;
  final String status;

  bool get isActive => status == 'active';

  bool matchesYear(int year) {
    if (yearFrom != null && year < yearFrom!) return false;
    if (yearTo != null && year > yearTo!) return false;
    return true;
  }
}

class VehicleAssetCatalog {
  const VehicleAssetCatalog({
    required this.catalogVersion,
    required this.studioProfileId,
    required this.entries,
    required this.fallbackChains,
    required this.universalPackId,
  });

  final String catalogVersion;
  final String studioProfileId;
  final List<VehicleCatalogRecord> entries;
  final Map<String, List<String>> fallbackChains;
  final String universalPackId;

  List<VehicleCatalogRecord> activeEntries() =>
      entries.where((e) => e.isActive).toList();
}
