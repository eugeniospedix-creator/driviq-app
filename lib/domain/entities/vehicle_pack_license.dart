class VehiclePackLicense {
  const VehiclePackLicense({
    required this.licenseId,
    required this.licenseType,
    required this.commercialUse,
    required this.appDistribution,
    required this.modification,
    required this.attributionRequired,
    this.attributionText,
    this.attributionUrl,
    this.acquisitionMethod,
    this.acquisitionDate,
  });

  final String licenseId;
  final String licenseType;
  final bool commercialUse;
  final bool appDistribution;
  final bool modification;
  final bool attributionRequired;
  final String? attributionText;
  final String? attributionUrl;
  final String? acquisitionMethod;
  final String? acquisitionDate;
}
