class Vehicle {
  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.modelAssetKey,
    required this.createdAt,
    required this.updatedAt,
    this.nickname,
    this.vin,
    this.mileageKm,
    this.photoPath,
    this.isPrimary = false,
  });

  final String id;
  final String make;
  final String model;
  final int year;
  final String? nickname;
  final String? vin;
  final int? mileageKm;
  final String? photoPath;

  /// Key into [VehicleCatalog] / future GLB asset pipeline.
  final String modelAssetKey;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName => nickname?.isNotEmpty == true ? nickname! : '$make $model';

  String get fullTitle => '$year $make $model';

  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? nickname,
    String? vin,
    int? mileageKm,
    String? photoPath,
    String? modelAssetKey,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      nickname: nickname ?? this.nickname,
      vin: vin ?? this.vin,
      mileageKm: mileageKm ?? this.mileageKm,
      photoPath: photoPath ?? this.photoPath,
      modelAssetKey: modelAssetKey ?? this.modelAssetKey,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
