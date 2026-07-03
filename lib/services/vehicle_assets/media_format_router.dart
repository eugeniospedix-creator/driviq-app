import 'package:flutter/widgets.dart';

import '../../domain/entities/resolved_vehicle_asset_pack.dart';
import '../../domain/enums/vehicle_media_format.dart';
import '../../domain/enums/vehicle_studio_role.dart';

/// Selects the correct media handler path from a resolved pack manifest.
/// Renderer code reads this router — never hardcodes format or marketplace logic.
abstract final class MediaFormatRouter {
  static String? selectRasterPath(
    ResolvedVehicleAssetPack pack,
    VehicleStudioRole role,
  ) {
    return pack.resolveMediaPath(role, preferFormat: VehicleMediaFormat.webp) ??
        pack.resolveMediaPath(role, preferFormat: VehicleMediaFormat.png);
  }

  static String? select3dPath(
    ResolvedVehicleAssetPack pack,
    VehicleStudioRole role,
  ) {
    return pack.resolveMediaPath(role, preferFormat: VehicleMediaFormat.glb) ??
        pack.resolveMediaPath(role, preferFormat: VehicleMediaFormat.usdz);
  }

  static Widget rasterImage({
    required String assetPath,
    required BoxFit fit,
    String? fallbackPath,
  }) {
    return Image.asset(
      assetPath,
      fit: fit,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: fallbackPath == null
          ? null
          : (_, _, _) => Image.asset(
                fallbackPath,
                fit: fit,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
    );
  }
}
