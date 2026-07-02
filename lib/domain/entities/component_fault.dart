import '../enums/component_zone.dart';
import '../enums/driveability.dart';
import '../enums/fault_severity.dart';

/// 3D-ready component anchor — x/y for 2D projection, z for future GLB mapping.
class ComponentAnchor {
  const ComponentAnchor({required this.x, required this.y, this.z = 0});

  final double x;
  final double y;
  final double z;
}

class ComponentFault {
  const ComponentFault({
    required this.id,
    required this.componentId,
    required this.name,
    required this.zone,
    required this.severity,
    required this.confidencePercent,
    required this.signalQualityPercent,
    required this.finding,
    required this.recommendation,
    required this.anchor,
    required this.driveability,
    required this.recommendedNextStep,
    this.whatHappened,
    this.whyItMatters,
    this.estimatedRepairCostMin,
    this.estimatedRepairCostMax,
    this.estimatedRepairHoursMin,
    this.estimatedRepairHoursMax,
    this.consequencesIfIgnored,
  });

  final String id;
  final String componentId;
  final String name;
  final ComponentZone zone;
  final FaultSeverity severity;
  final int confidencePercent;
  final int signalQualityPercent;
  final String finding;
  final String recommendation;
  final ComponentAnchor anchor;
  final Driveability driveability;
  final String recommendedNextStep;
  final String? whatHappened;
  final String? whyItMatters;
  final double? estimatedRepairCostMin;
  final double? estimatedRepairCostMax;
  final double? estimatedRepairHoursMin;
  final double? estimatedRepairHoursMax;
  final String? consequencesIfIgnored;
}
