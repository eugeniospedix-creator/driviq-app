import '../enums/vehicle_asset_resolution_kind.dart';
import '../enums/vehicle_media_format.dart';
import '../enums/vehicle_studio_role.dart';
import 'vehicle_pack_license.dart';
import 'vehicle_pack_manifest.dart';

/// Fully resolved asset pack ready for presentation — always valid, never empty.
class ResolvedVehicleAssetPack {
  const ResolvedVehicleAssetPack({
    required this.packId,
    required this.manifest,
    required this.license,
    required this.resolution,
    required this.bundleRoot,
    this.mediaPackId,
    this.fallbackPackId,
  });

  final String packId;
  final VehiclePackManifest manifest;
  final VehiclePackLicense license;
  final VehicleAssetResolutionKind resolution;
  final String bundleRoot;
  final String? mediaPackId;
  final String? fallbackPackId;

  String get _mediaRoot => mediaPackId ?? packId;

  String assetPrefix() => '$bundleRoot/$_mediaRoot/';

  String? resolveMediaPath(VehicleStudioRole role, {VehicleMediaFormat? preferFormat}) {
    final candidates = manifest.mediaForRoleAllFormats(role);
    if (candidates.isEmpty) return null;

    if (preferFormat != null) {
      for (final asset in candidates) {
        if (asset.format == preferFormat) return '${assetPrefix()}${asset.path}';
      }
    }

    for (final format in const [VehicleMediaFormat.webp, VehicleMediaFormat.png, VehicleMediaFormat.glb]) {
      for (final asset in candidates) {
        if (asset.format == format) return '${assetPrefix()}${asset.path}';
      }
    }

    final first = candidates.first;
    return '${assetPrefix()}${first.path}';
  }

  String resolveMediaPathOrFallback(VehicleStudioRole role) {
    return resolveMediaPath(role) ?? '${assetPrefix()}media/studio_master.png';
  }
}
