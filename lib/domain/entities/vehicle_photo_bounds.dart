/// Normalized bounding box of the detected vehicle in the source image (0–1).
class VehiclePhotoBounds {
  const VehiclePhotoBounds({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}
