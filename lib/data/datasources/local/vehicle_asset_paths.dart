/// Bundled asset path constants for the vehicle pack registry.
abstract final class VehicleAssetPaths {
  static const bundleRoot = 'assets/vehicles/packs';
  static const registryRoot = 'assets/vehicles/registry';

  static const catalog = '$registryRoot/catalog.v1.json';
  static const fallbackChain = '$registryRoot/fallback-chain.v1.json';
  static const studioProfile = '$registryRoot/studio-profile.v1.json';

  static String packManifest(String packId) => '$bundleRoot/$packId/manifest.json';
  static String packLicense(String packId) => '$bundleRoot/$packId/license.json';
  static String packAnchors(String packId) => '$bundleRoot/$packId/anchors.json';
}
