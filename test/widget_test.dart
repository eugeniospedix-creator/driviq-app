import 'package:flutter_test/flutter_test.dart';

import 'package:driviq/data/catalog/vehicle_catalog.dart';
import 'package:driviq/domain/enums/fault_severity.dart';
import 'package:driviq/domain/enums/health_status.dart';

void main() {
  test('vehicle catalog resolves known makes and models', () {
    final tesla = VehicleCatalog.resolve('Tesla', 'Model 3');
    expect(tesla?.assetKey, 'tesla_model_3');

    final bmw = VehicleCatalog.resolve('BMW', 'M340i xDrive');
    expect(bmw?.assetKey, 'bmw_m340i');
  });

  test('health status labels are human readable', () {
    expect(HealthStatus.excellent.label, 'Excellent');
    expect(FaultSeverity.attention.label, 'Attention');
  });
}
