import '../../domain/catalog/vehicle_component_hotspot_layout.dart';
import '../../domain/entities/component_fault.dart';
import '../../domain/enums/component_zone.dart';
import '../../domain/enums/driveability.dart';
import '../../domain/enums/fault_severity.dart';

/// Aligns scan faults to the standard vehicle studio layout for report hotspots.
abstract final class ReportComponentMapper {
  static const _primaryComponents = [
    'engine',
    'front_left_wheel',
    'rear_left_wheel',
    'brakes',
    'suspension',
    'exhaust',
    'battery',
    'transmission',
  ];

  static List<ComponentFault> hotspotsForReport(List<ComponentFault> scanFaults) {
    final byComponent = <String, ComponentFault>{};
    for (final fault in scanFaults) {
      byComponent[fault.componentId] = fault;
    }

    return _primaryComponents.map((componentId) {
      final existing = byComponent[componentId];
      final anchor = VehicleComponentHotspotLayout.anchorFor(
        componentId,
        fallback: existing?.anchor,
      );
      if (existing != null) {
        return ComponentFault(
          id: existing.id,
          componentId: existing.componentId,
          name: existing.name,
          zone: existing.zone,
          severity: existing.severity,
          confidencePercent: existing.confidencePercent,
          signalQualityPercent: existing.signalQualityPercent,
          finding: existing.finding,
          recommendation: existing.recommendation,
          anchor: anchor,
          driveability: existing.driveability,
          recommendedNextStep: existing.recommendedNextStep,
          whatHappened: existing.whatHappened,
          whyItMatters: existing.whyItMatters,
          estimatedRepairCostMin: existing.estimatedRepairCostMin,
          estimatedRepairCostMax: existing.estimatedRepairCostMax,
          estimatedRepairHoursMin: existing.estimatedRepairHoursMin,
          estimatedRepairHoursMax: existing.estimatedRepairHoursMax,
          consequencesIfIgnored: existing.consequencesIfIgnored,
        );
      }

      return ComponentFault(
        id: 'component_$componentId',
        componentId: componentId,
        name: VehicleComponentHotspotLayout.displayNames[componentId] ?? componentId,
        zone: ComponentZone.powertrain,
        severity: FaultSeverity.monitor,
        confidencePercent: 0,
        signalQualityPercent: 0,
        finding: 'No issues flagged in the latest scan.',
        recommendation: 'Continue routine monitoring.',
        anchor: anchor,
        driveability: Driveability.safe,
        recommendedNextStep: 'Run another scan after significant mileage or if symptoms appear.',
      );
    }).toList();
  }
}
