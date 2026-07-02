import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/scan_session.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/enums/component_zone.dart';
import '../../../domain/enums/driveability.dart';
import '../../../domain/enums/fault_severity.dart';
import '../../../domain/enums/health_status.dart';
import '../../../domain/enums/scan_source.dart';
import '../../../domain/repositories/diagnosis_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/repositories/vehicle_repository.dart';
import '../../../domain/catalog/vehicle_catalog.dart';
import '../../../domain/entities/app_settings.dart';
import 'hive_local_store.dart';

class LocalDataSeeder {
  LocalDataSeeder({
    required this.store,
    required this.vehicles,
    required this.diagnosis,
    required this.settings,
  });

  final HiveLocalStore store;
  final VehicleRepository vehicles;
  final DiagnosisRepository diagnosis;
  final SettingsRepository settings;
  static const _uuid = Uuid();

  Future<void> seedIfNeeded() async {
    if (store.seedVersion >= AppConstants.seedVersion) return;

    // Never overwrite an existing user garage — demo content is first-install only.
    if (store.vehicles.isNotEmpty) {
      await store.setSeedVersion(AppConstants.seedVersion);
      return;
    }

    final now = DateTime.now();
    final bmwId = _uuid.v4();
    final audiId = _uuid.v4();

    final bmw = Vehicle(
      id: bmwId,
      make: VehicleCatalog.bmwM340i.make,
      model: VehicleCatalog.bmwM340i.model,
      year: VehicleCatalog.bmwM340i.defaultYear,
      modelAssetKey: VehicleCatalog.bmwM340i.assetKey,
      nickname: 'Daily Driver',
      mileageKm: 48200,
      isPrimary: true,
      createdAt: now.subtract(const Duration(days: 120)),
      updatedAt: now,
    );

    final audi = Vehicle(
      id: audiId,
      make: VehicleCatalog.audiA3.make,
      model: VehicleCatalog.audiA3.model,
      year: VehicleCatalog.audiA3.defaultYear,
      modelAssetKey: VehicleCatalog.audiA3.assetKey,
      mileageKm: 91300,
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    );

    await vehicles.save(bmw);
    await vehicles.save(audi);

    await diagnosis.save(_bmwScan(bmwId, now));
    await diagnosis.save(_audiScan(audiId, now.subtract(const Duration(days: 2))));

    await settings.save(const AppSettings(
      microphoneEnabled: true,
      motionSensorsEnabled: true,
      privacyMode: true,
      safeDrivingMode: true,
      cloudAiEnabled: false,
      offlineAiEnabled: true,
      obdEnabled: false,
      arPreviewEnabled: false,
    ));

    await store.setSeedVersion(AppConstants.seedVersion);
    await store.setSchemaVersion(1);
  }

  ScanSession _bmwScan(String vehicleId, DateTime now) {
    return ScanSession(
      id: _uuid.v4(),
      vehicleId: vehicleId,
      startedAt: now.subtract(const Duration(minutes: 4)),
      completedAt: now.subtract(const Duration(minutes: 1)),
      healthScore: 98,
      healthStatus: HealthStatus.excellent,
      summary: 'No critical anomaly detected in the latest baseline.',
      sources: const [ScanSource.microphone, ScanSource.accelerometer, ScanSource.offlineAi],
      faults: _bmwFaults(),
    );
  }

  ScanSession _audiScan(String vehicleId, DateTime completedAt) {
    return ScanSession(
      id: _uuid.v4(),
      vehicleId: vehicleId,
      startedAt: completedAt.subtract(const Duration(minutes: 5)),
      completedAt: completedAt,
      healthScore: 82,
      healthStatus: HealthStatus.attention,
      summary: 'Front wheel bearing pattern requires inspection within 7 days.',
      sources: const [ScanSource.microphone, ScanSource.gyroscope, ScanSource.offlineAi],
      faults: _audiFaults(),
    );
  }

  List<ComponentFault> _bmwFaults() => [
        ComponentFault(
          id: _uuid.v4(),
          componentId: 'engine',
          name: 'Engine Bay',
          zone: ComponentZone.powertrain,
          severity: FaultSeverity.normal,
          confidencePercent: 94,
          signalQualityPercent: 96,
          finding: 'Combustion and belt frequency within expected range.',
          recommendation: 'No immediate action. Repeat scan after 500 km.',
          anchor: const ComponentAnchor(x: 0.62, y: 0.42),
          driveability: Driveability.safe,
          recommendedNextStep: 'Continue routine monitoring.',
          whatHappened: 'Engine harmonics match your vehicle baseline.',
          whyItMatters: 'Stable combustion patterns indicate healthy power delivery.',
        ),
        ComponentFault(
          id: _uuid.v4(),
          componentId: 'front_right',
          name: 'Front Right Bearing',
          zone: ComponentZone.wheelAssembly,
          severity: FaultSeverity.monitor,
          confidencePercent: 72,
          signalQualityPercent: 91,
          finding: 'Minor rotational pattern near front wheel frequency band.',
          recommendation: 'Monitor during next 300 km. Inspect if noise increases.',
          anchor: const ComponentAnchor(x: 0.28, y: 0.68),
          driveability: Driveability.caution,
          recommendedNextStep: 'Schedule inspection if humming persists above 40 km/h.',
          whatHappened: 'Slight elevation in wheel rotation harmonics.',
          whyItMatters: 'Early bearing wear often appears as subtle acoustic drift.',
          estimatedRepairCostMin: 180,
          estimatedRepairCostMax: 420,
          estimatedRepairHoursMin: 1.5,
          estimatedRepairHoursMax: 3,
          consequencesIfIgnored: 'Progressive wear can damage the hub and increase stopping distance.',
        ),
        ComponentFault(
          id: _uuid.v4(),
          componentId: 'brakes',
          name: 'Brake System',
          zone: ComponentZone.frictionSystem,
          severity: FaultSeverity.normal,
          confidencePercent: 88,
          signalQualityPercent: 93,
          finding: 'Friction system within baseline tolerance.',
          recommendation: 'No urgent action required.',
          anchor: const ComponentAnchor(x: 0.38, y: 0.69),
          driveability: Driveability.safe,
          recommendedNextStep: 'Visual pad inspection at next service.',
        ),
        ComponentFault(
          id: _uuid.v4(),
          componentId: 'suspension',
          name: 'Rear Suspension',
          zone: ComponentZone.chassis,
          severity: FaultSeverity.normal,
          confidencePercent: 91,
          signalQualityPercent: 94,
          finding: 'Vertical vibration within baseline range.',
          recommendation: 'No urgent action.',
          anchor: const ComponentAnchor(x: 0.73, y: 0.69),
          driveability: Driveability.safe,
          recommendedNextStep: 'Continue monitoring.',
        ),
        ComponentFault(
          id: _uuid.v4(),
          componentId: 'exhaust',
          name: 'Exhaust Resonance',
          zone: ComponentZone.exhaust,
          severity: FaultSeverity.monitor,
          confidencePercent: 69,
          signalQualityPercent: 84,
          finding: 'Low-frequency resonance slightly above idle profile.',
          recommendation: 'Repeat scan with cold and warm engine.',
          anchor: const ComponentAnchor(x: 0.83, y: 0.50),
          driveability: Driveability.caution,
          recommendedNextStep: 'Check exhaust mounts at next stop.',
          consequencesIfIgnored: 'Loose mounts can amplify cabin noise and stress joints.',
        ),
      ];

  List<ComponentFault> _audiFaults() => [
        ComponentFault(
          id: _uuid.v4(),
          componentId: 'front_right',
          name: 'Front Right Bearing',
          zone: ComponentZone.wheelAssembly,
          severity: FaultSeverity.attention,
          confidencePercent: 82,
          signalQualityPercent: 97,
          finding: 'Rotational acoustic pattern detected near front wheel frequency band.',
          recommendation: 'Inspect bearing, brake disc and suspension linkage within 7 days.',
          anchor: const ComponentAnchor(x: 0.28, y: 0.68),
          driveability: Driveability.caution,
          recommendedNextStep: 'Book inspection this week.',
          whatHappened: 'Abnormal harmonic signature while coasting above 35 km/h.',
          whyItMatters: 'Wheel bearings support rotational load — degradation reduces stability.',
          estimatedRepairCostMin: 220,
          estimatedRepairCostMax: 510,
          estimatedRepairHoursMin: 2,
          estimatedRepairHoursMax: 4,
          consequencesIfIgnored: 'Failure can cause wheel lock-up risk and collateral hub damage.',
        ),
        ComponentFault(
          id: _uuid.v4(),
          componentId: 'engine',
          name: 'Engine Bay',
          zone: ComponentZone.powertrain,
          severity: FaultSeverity.normal,
          confidencePercent: 90,
          signalQualityPercent: 92,
          finding: 'Diesel combustion profile stable.',
          recommendation: 'No immediate action.',
          anchor: const ComponentAnchor(x: 0.62, y: 0.42),
          driveability: Driveability.safe,
          recommendedNextStep: 'Standard service interval.',
        ),
      ];
}
