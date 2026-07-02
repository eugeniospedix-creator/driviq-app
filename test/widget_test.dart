import 'package:flutter_test/flutter_test.dart';

import 'package:driviq/domain/catalog/vehicle_catalog.dart';
import 'package:driviq/domain/enums/fault_severity.dart';
import 'package:driviq/domain/enums/health_status.dart';
import 'package:driviq/domain/extensions/app_settings_scan.dart';
import 'package:driviq/domain/entities/app_settings.dart';

void main() {
  group('VehicleCatalog', () {
    test('resolves known makes and models', () {
      expect(VehicleCatalog.resolve('Tesla', 'Model 3')?.assetKey, 'tesla_model_3');
      expect(VehicleCatalog.resolve('BMW', 'M340i xDrive')?.assetKey, 'bmw_m340i');
    });

    test('falls back to generic sedan', () {
      expect(VehicleCatalog.resolveOrDefault('Unknown', 'Car').assetKey, 'generic_sedan');
    });
  });

  group('AppSettings', () {
    test('requires microphone and AI for scans', () {
      const disabled = AppSettings(microphoneEnabled: false, offlineAiEnabled: true);
      expect(disabled.canRunScan(), isFalse);

      const enabled = AppSettings(microphoneEnabled: true, offlineAiEnabled: true);
      expect(enabled.canRunScan(), isTrue);
    });
  });

  group('Labels', () {
    test('health status labels are human readable', () {
      expect(HealthStatus.excellent.label, 'Excellent');
      expect(FaultSeverity.attention.label, 'Attention');
    });
  });
}
