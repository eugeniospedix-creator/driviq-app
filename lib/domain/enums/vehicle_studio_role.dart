/// Studio-processed presentation roles — every role is a Driviq pipeline output.
enum VehicleStudioRole {
  studioMaster('studio_master'),
  heroHome('hero_home'),
  heroGarage('hero_garage'),
  heroScan('hero_scan'),
  heroReport('hero_report'),
  thumbnail('thumbnail'),
  exterior3d('exterior_3d'),
  exteriorAr('exterior_ar');

  const VehicleStudioRole(this.key);

  final String key;

  static VehicleStudioRole? fromKey(String key) {
    for (final role in values) {
      if (role.key == key) return role;
    }
    return null;
  }
}
