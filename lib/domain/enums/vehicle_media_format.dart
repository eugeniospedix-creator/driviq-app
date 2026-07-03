/// Supported media formats in the asset pipeline — extensible without renderer changes.
enum VehicleMediaFormat {
  png('png'),
  webp('webp'),
  glb('glb'),
  usdz('usdz');

  const VehicleMediaFormat(this.key);

  final String key;

  static VehicleMediaFormat? fromKey(String key) {
    for (final format in values) {
      if (format.key == key) return format;
    }
    return null;
  }
}
