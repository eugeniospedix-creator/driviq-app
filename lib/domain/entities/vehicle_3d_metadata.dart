import '../enums/vehicle_view_mode.dart';

class ComponentAnchor3D {
  const ComponentAnchor3D({
    required this.componentId,
    required this.positions,
  });

  final String componentId;
  final Map<VehicleViewMode, AnchorPosition3D> positions;

  AnchorPosition3D forView(VehicleViewMode mode) =>
      positions[mode] ?? positions[VehicleViewMode.exterior] ?? const AnchorPosition3D();
}

class AnchorPosition3D {
  const AnchorPosition3D({this.x = 0.5, this.y = 0.5, this.z = 0});

  final double x;
  final double y;
  final double z;

  factory AnchorPosition3D.fromJson(Map<String, dynamic> json) => AnchorPosition3D(
        x: (json['x'] as num?)?.toDouble() ?? 0.5,
        y: (json['y'] as num?)?.toDouble() ?? 0.5,
        z: (json['z'] as num?)?.toDouble() ?? 0,
      );
}

class Vehicle3DMetadata {
  const Vehicle3DMetadata({
    required this.assetKey,
    required this.bodyType,
    required this.anchors,
    this.glbAssetPath,
    this.stagingLabel,
  });

  final String assetKey;
  final String bodyType;
  final String? glbAssetPath;
  final String? stagingLabel;
  final List<ComponentAnchor3D> anchors;

  ComponentAnchor3D? anchorFor(String componentId) {
    for (final anchor in anchors) {
      if (anchor.componentId == componentId) return anchor;
    }
    return null;
  }
}
