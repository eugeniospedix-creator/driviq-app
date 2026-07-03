import '../entities/resolved_vehicle_asset_pack.dart';
import '../entities/vehicle_asset_catalog.dart';
import '../entities/vehicle_pack_license.dart';
import '../entities/vehicle_pack_manifest.dart';

abstract class VehicleAssetRepository {
  Future<VehicleAssetCatalog> loadCatalog();

  Future<VehiclePackManifest> loadPackManifest(String packId);

  Future<VehiclePackLicense> loadPackLicense(String packId);

  Future<ResolvedVehicleAssetPack> resolveForVehicle({
    required String make,
    required String model,
    required int year,
    String? modelAssetKey,
  });
}
