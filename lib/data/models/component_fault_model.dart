import '../../domain/entities/component_fault.dart';
import '../../domain/enums/component_zone.dart';
import '../../domain/enums/driveability.dart';
import '../../domain/enums/fault_severity.dart';

class ComponentFaultModel {
  const ComponentFaultModel({
    required this.id,
    required this.componentId,
    required this.name,
    required this.zone,
    required this.severity,
    required this.confidencePercent,
    required this.signalQualityPercent,
    required this.finding,
    required this.recommendation,
    required this.anchorX,
    required this.anchorY,
    required this.anchorZ,
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
  final String zone;
  final String severity;
  final int confidencePercent;
  final int signalQualityPercent;
  final String finding;
  final String recommendation;
  final double anchorX;
  final double anchorY;
  final double anchorZ;
  final String driveability;
  final String recommendedNextStep;
  final String? whatHappened;
  final String? whyItMatters;
  final double? estimatedRepairCostMin;
  final double? estimatedRepairCostMax;
  final double? estimatedRepairHoursMin;
  final double? estimatedRepairHoursMax;
  final String? consequencesIfIgnored;

  factory ComponentFaultModel.fromEntity(ComponentFault entity) => ComponentFaultModel(
        id: entity.id,
        componentId: entity.componentId,
        name: entity.name,
        zone: entity.zone.name,
        severity: entity.severity.name,
        confidencePercent: entity.confidencePercent,
        signalQualityPercent: entity.signalQualityPercent,
        finding: entity.finding,
        recommendation: entity.recommendation,
        anchorX: entity.anchor.x,
        anchorY: entity.anchor.y,
        anchorZ: entity.anchor.z,
        driveability: entity.driveability.name,
        recommendedNextStep: entity.recommendedNextStep,
        whatHappened: entity.whatHappened,
        whyItMatters: entity.whyItMatters,
        estimatedRepairCostMin: entity.estimatedRepairCostMin,
        estimatedRepairCostMax: entity.estimatedRepairCostMax,
        estimatedRepairHoursMin: entity.estimatedRepairHoursMin,
        estimatedRepairHoursMax: entity.estimatedRepairHoursMax,
        consequencesIfIgnored: entity.consequencesIfIgnored,
      );

  ComponentFault toEntity() => ComponentFault(
        id: id,
        componentId: componentId,
        name: name,
        zone: ComponentZone.values.byName(zone),
        severity: FaultSeverity.values.byName(severity),
        confidencePercent: confidencePercent,
        signalQualityPercent: signalQualityPercent,
        finding: finding,
        recommendation: recommendation,
        anchor: ComponentAnchor(x: anchorX, y: anchorY, z: anchorZ),
        driveability: Driveability.values.byName(driveability),
        recommendedNextStep: recommendedNextStep,
        whatHappened: whatHappened,
        whyItMatters: whyItMatters,
        estimatedRepairCostMin: estimatedRepairCostMin,
        estimatedRepairCostMax: estimatedRepairCostMax,
        estimatedRepairHoursMin: estimatedRepairHoursMin,
        estimatedRepairHoursMax: estimatedRepairHoursMax,
        consequencesIfIgnored: consequencesIfIgnored,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'componentId': componentId,
        'name': name,
        'zone': zone,
        'severity': severity,
        'confidencePercent': confidencePercent,
        'signalQualityPercent': signalQualityPercent,
        'finding': finding,
        'recommendation': recommendation,
        'anchorX': anchorX,
        'anchorY': anchorY,
        'anchorZ': anchorZ,
        'driveability': driveability,
        'recommendedNextStep': recommendedNextStep,
        'whatHappened': whatHappened,
        'whyItMatters': whyItMatters,
        'estimatedRepairCostMin': estimatedRepairCostMin,
        'estimatedRepairCostMax': estimatedRepairCostMax,
        'estimatedRepairHoursMin': estimatedRepairHoursMin,
        'estimatedRepairHoursMax': estimatedRepairHoursMax,
        'consequencesIfIgnored': consequencesIfIgnored,
      };

  factory ComponentFaultModel.fromJson(Map<dynamic, dynamic> json) => ComponentFaultModel(
        id: json['id'] as String,
        componentId: json['componentId'] as String,
        name: json['name'] as String,
        zone: json['zone'] as String,
        severity: json['severity'] as String,
        confidencePercent: json['confidencePercent'] as int,
        signalQualityPercent: json['signalQualityPercent'] as int,
        finding: json['finding'] as String,
        recommendation: json['recommendation'] as String,
        anchorX: (json['anchorX'] as num).toDouble(),
        anchorY: (json['anchorY'] as num).toDouble(),
        anchorZ: (json['anchorZ'] as num?)?.toDouble() ?? 0,
        driveability: json['driveability'] as String,
        recommendedNextStep: json['recommendedNextStep'] as String,
        whatHappened: json['whatHappened'] as String?,
        whyItMatters: json['whyItMatters'] as String?,
        estimatedRepairCostMin: (json['estimatedRepairCostMin'] as num?)?.toDouble(),
        estimatedRepairCostMax: (json['estimatedRepairCostMax'] as num?)?.toDouble(),
        estimatedRepairHoursMin: (json['estimatedRepairHoursMin'] as num?)?.toDouble(),
        estimatedRepairHoursMax: (json['estimatedRepairHoursMax'] as num?)?.toDouble(),
        consequencesIfIgnored: json['consequencesIfIgnored'] as String?,
      );
}
