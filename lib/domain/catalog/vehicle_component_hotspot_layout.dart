import '../entities/component_fault.dart';

/// Normalized hotspot anchors for a side-profile vehicle studio photo.
abstract final class VehicleComponentHotspotLayout {
  static const Map<String, ComponentAnchor> anchors = {
    'engine': ComponentAnchor(x: 0.58, y: 0.40, z: 0.12),
    'front_left_wheel': ComponentAnchor(x: 0.24, y: 0.74, z: -0.08),
    'front_right_wheel': ComponentAnchor(x: 0.24, y: 0.74, z: 0.08),
    'rear_left_wheel': ComponentAnchor(x: 0.78, y: 0.74, z: -0.08),
    'rear_right_wheel': ComponentAnchor(x: 0.78, y: 0.74, z: 0.08),
    'brakes': ComponentAnchor(x: 0.30, y: 0.68, z: 0.0),
    'suspension': ComponentAnchor(x: 0.46, y: 0.70, z: 0.0),
    'exhaust': ComponentAnchor(x: 0.84, y: 0.62, z: 0.0),
    'battery': ComponentAnchor(x: 0.52, y: 0.48, z: 0.06),
    'transmission': ComponentAnchor(x: 0.50, y: 0.56, z: 0.0),
  };

  static const Map<String, String> displayNames = {
    'engine': 'Engine',
    'front_left_wheel': 'Front wheel',
    'front_right_wheel': 'Front wheel',
    'rear_left_wheel': 'Rear wheel',
    'rear_right_wheel': 'Rear wheel',
    'brakes': 'Brakes',
    'suspension': 'Suspension',
    'exhaust': 'Exhaust',
    'battery': 'Battery',
    'transmission': 'Transmission',
  };

  static ComponentAnchor anchorFor(String componentId, {ComponentAnchor? fallback}) {
    return anchors[componentId] ?? fallback ?? const ComponentAnchor(x: 0.5, y: 0.5);
  }

  static ComponentFault? faultForComponent(String componentId, List<ComponentFault> faults) {
    for (final fault in faults) {
      if (fault.componentId == componentId) return fault;
    }
    return null;
  }
}
