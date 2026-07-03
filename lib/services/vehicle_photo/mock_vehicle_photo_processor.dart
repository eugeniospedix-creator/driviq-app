import '../../domain/entities/vehicle_photo_bounds.dart';
import '../../domain/entities/vehicle_photo_detection.dart';
import '../../domain/entities/vehicle_photo_process_result.dart';
import 'smart_vehicle_photo_processor.dart';

/// Legacy alias — delegates to [SmartVehiclePhotoProcessor].
@Deprecated('Use SmartVehiclePhotoProcessor')
class MockVehiclePhotoProcessor extends SmartVehiclePhotoProcessor {
  MockVehiclePhotoProcessor(super.photos);

  @override
  Future<VehiclePhotoDetection> analyze({required String sourceImagePath}) =>
      super.analyze(sourceImagePath: sourceImagePath);

  @override
  Future<VehiclePhotoProcessResult> process({
    required String sourceImagePath,
    required String vehicleId,
    VehiclePhotoBounds? cropBounds,
  }) =>
      super.process(
        sourceImagePath: sourceImagePath,
        vehicleId: vehicleId,
        cropBounds: cropBounds,
      );
}
