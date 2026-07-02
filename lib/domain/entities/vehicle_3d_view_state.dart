/// Interactive 3D camera state — yaw/pitch/zoom for the vehicle viewer.
class Vehicle3DViewState {
  const Vehicle3DViewState({
    this.yaw = 0.32,
    this.pitch = 0.12,
    this.zoom = 1.0,
  });

  final double yaw;
  final double pitch;
  final double zoom;

  static const minZoom = 0.65;
  static const maxZoom = 1.85;

  Vehicle3DViewState copyWith({
    double? yaw,
    double? pitch,
    double? zoom,
  }) {
    return Vehicle3DViewState(
      yaw: yaw ?? this.yaw,
      pitch: pitch ?? this.pitch,
      zoom: (zoom ?? this.zoom).clamp(minZoom, maxZoom),
    );
  }
}
