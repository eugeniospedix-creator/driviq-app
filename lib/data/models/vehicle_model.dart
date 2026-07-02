import '../../domain/entities/vehicle.dart';

class VehicleModel {
  const VehicleModel({
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
  final String modelAssetKey;
  final bool isPrimary;
  final String createdAt;
  final String updatedAt;

  factory VehicleModel.fromEntity(Vehicle entity) => VehicleModel(
        id: entity.id,
        make: entity.make,
        model: entity.model,
        year: entity.year,
        nickname: entity.nickname,
        vin: entity.vin,
        mileageKm: entity.mileageKm,
        photoPath: entity.photoPath,
        modelAssetKey: entity.modelAssetKey,
        isPrimary: entity.isPrimary,
        createdAt: entity.createdAt.toIso8601String(),
        updatedAt: entity.updatedAt.toIso8601String(),
      );

  Vehicle toEntity() => Vehicle(
        id: id,
        make: make,
        model: model,
        year: year,
        nickname: nickname,
        vin: vin,
        mileageKm: mileageKm,
        photoPath: photoPath,
        modelAssetKey: modelAssetKey,
        isPrimary: isPrimary,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'model': model,
        'year': year,
        'nickname': nickname,
        'vin': vin,
        'mileageKm': mileageKm,
        'photoPath': photoPath,
        'modelAssetKey': modelAssetKey,
        'isPrimary': isPrimary,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory VehicleModel.fromJson(Map<dynamic, dynamic> json) => VehicleModel(
        id: json['id'] as String,
        make: json['make'] as String,
        model: json['model'] as String,
        year: json['year'] as int,
        nickname: json['nickname'] as String?,
        vin: json['vin'] as String?,
        mileageKm: json['mileageKm'] as int?,
        photoPath: json['photoPath'] as String?,
        modelAssetKey: json['modelAssetKey'] as String,
        isPrimary: json['isPrimary'] as bool? ?? false,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}
