import 'dart:io';

import 'package:image/image.dart' as img;

import '../../domain/entities/vehicle_photo_bounds.dart';
import '../../domain/entities/vehicle_photo_detection.dart';
import '../../domain/entities/vehicle_photo_process_result.dart';
import '../../domain/errors/app_exception.dart';
import '../../domain/repositories/vehicle_photo_repository.dart';
import '../interfaces/vehicle_photo_processor.dart';
import 'native_vehicle_segmentation.dart';
import 'smart_vehicle_photo_processor.dart';
import 'vehicle_background_removal_engine.dart';
import 'vehicle_photo_image_utils.dart';
import 'vehicle_photo_quality.dart';

/// Production vehicle cutout — Apple Vision / ML Kit mask + refined matte pipeline.
class AiVehiclePhotoProcessor implements VehiclePhotoProcessor {
  AiVehiclePhotoProcessor(this._photos)
      : _detector = SmartVehiclePhotoProcessor(_photos),
        _removal = const VehicleBackgroundRemovalEngine();

  final VehiclePhotoRepository _photos;
  final SmartVehiclePhotoProcessor _detector;
  final VehicleBackgroundRemovalEngine _removal;

  @override
  Future<VehiclePhotoDetection> analyze({required String sourceImagePath}) async {
    final decoded = await _decode(sourceImagePath);
    final sourceQuality = assessSourceImage(decoded);

    final native = await NativeVehicleSegmentation.segment(sourceImagePath);
    VehiclePhotoDetection detection;
    if (native != null && native.confidence >= 0.55) {
      detection = VehiclePhotoDetection(
        bounds: premiumMarginBounds(native.bounds),
        confidence: native.confidence,
      );
    } else {
      final heuristic = await _detector.analyze(sourceImagePath: sourceImagePath);
      detection = VehiclePhotoDetection(
        bounds: premiumMarginBounds(heuristic.bounds),
        confidence: heuristic.confidence,
      );
    }

    var confidence = detection.confidence;
    if (!sourceQuality.ok) confidence = confidence.clamp(0.0, 0.35);

    final coverage = assessBoundsCoverage(detection.bounds);
    if (!coverage.ok) {
      return VehiclePhotoDetection(bounds: detection.bounds, confidence: confidence.clamp(0.0, 0.34));
    }

    return VehiclePhotoDetection(bounds: detection.bounds, confidence: confidence);
  }

  @override
  Future<VehiclePhotoProcessResult> process({
    required String sourceImagePath,
    required String vehicleId,
    VehiclePhotoBounds? cropBounds,
  }) async {
    final decoded = await _decode(sourceImagePath);
    final manual = cropBounds != null;

    if (!manual) {
      final sourceQuality = assessSourceImage(decoded);
      if (!sourceQuality.ok) {
        throw VehiclePhotoException(sourceQuality.userMessage ?? 'Photo quality too low.');
      }
    }

    final detection = manual
        ? VehiclePhotoDetection(bounds: clampBounds(cropBounds), confidence: 1.0)
        : await analyze(sourceImagePath: sourceImagePath);

    if (!manual && detection.confidence < VehiclePhotoDetection.confidenceThreshold) {
      throw const VehiclePhotoException('Could not detect your vehicle. Adjust the crop.');
    }

    final cropRect = photoBoundsToPixelRect(decoded.width, decoded.height, detection.bounds);
    var cropped = img.copyCrop(
      decoded,
      x: cropRect.left,
      y: cropRect.top,
      width: cropRect.width,
      height: cropRect.height,
    );
    cropped = resizeIfNeeded(cropped, maxSide: 1600);

    final removal = await _removal.removeBackground(source: cropped, sourcePath: sourceImagePath);
    var cutout = removal.cutout;
    cutout = enhanceStudioLighting(cutout);
    cutout = addPremiumCanvasPadding(cutout);

    final quality = assessCutout(
      cutout,
      confidence: manual ? 0.99 : removal.confidence,
    );
    if (!quality.ok && !manual) {
      throw VehiclePhotoException(quality.userMessage ?? 'Cutout quality too low.');
    }

    final png = img.encodePng(cutout);
    final outputPath = await _photos.saveProcessedPng(vehicleId: vehicleId, pngBytes: png);

    return VehiclePhotoProcessResult(
      localPath: outputPath,
      confidence: manual ? 0.95 : removal.confidence,
      bounds: detection.bounds,
      processedAt: DateTime.now(),
    );
  }

  Future<img.Image> _decode(String path) async {
    final file = File(path);
    if (!await file.exists()) throw const VehiclePhotoException('Source image not found.');
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const VehiclePhotoException('Could not read the selected image.');
    return decoded;
  }
}
