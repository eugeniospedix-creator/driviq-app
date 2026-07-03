import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

import '../../domain/entities/vehicle_photo_bounds.dart';
import '../../domain/entities/vehicle_photo_detection.dart';
import '../../domain/entities/vehicle_photo_process_result.dart';
import '../../domain/errors/app_exception.dart';
import '../../domain/repositories/vehicle_photo_repository.dart';
import '../interfaces/vehicle_photo_processor.dart';
import 'vehicle_photo_image_utils.dart';

/// Content-aware crop + edge-connected background removal.
/// Replace internals with Vision / ML Kit / cloud API without changing callers.
class SmartVehiclePhotoProcessor implements VehiclePhotoProcessor {
  SmartVehiclePhotoProcessor(this._photos);

  final VehiclePhotoRepository _photos;

  @override
  Future<VehiclePhotoDetection> analyze({required String sourceImagePath}) async {
    final decoded = await _decode(sourceImagePath);
    return _detectSubject(decoded);
  }

  @override
  Future<VehiclePhotoProcessResult> process({
    required String sourceImagePath,
    required String vehicleId,
    VehiclePhotoBounds? cropBounds,
  }) async {
    final decoded = await _decode(sourceImagePath);
    final detection = cropBounds != null
        ? VehiclePhotoDetection(bounds: clampBounds(cropBounds), confidence: 1.0)
        : _detectSubject(decoded);

    final cropRect = photoBoundsToPixelRect(
      decoded.width,
      decoded.height,
      detection.bounds,
    );

    var cropped = img.copyCrop(
      decoded,
      x: cropRect.left,
      y: cropRect.top,
      width: cropRect.width,
      height: cropRect.height,
    );
    cropped = resizeIfNeeded(cropped);

    final cutout = _removeBackground(cropped);
    final png = img.encodePng(cutout);
    final outputPath = await _photos.saveProcessedPng(
      vehicleId: vehicleId,
      pngBytes: png,
    );

    return VehiclePhotoProcessResult(
      localPath: outputPath,
      confidence: detection.confidence,
      bounds: detection.bounds,
      processedAt: DateTime.now(),
    );
  }

  Future<img.Image> _decode(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw const VehiclePhotoException('Source image not found.');
    }
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const VehiclePhotoException('Could not read the selected image.');
    }
    return decoded;
  }

  VehiclePhotoDetection _detectSubject(img.Image image) {
    final bg = estimateBackgroundColor(image);
    final w = image.width;
    final h = image.height;
    final yStart = (h * 0.10).round();
    final yEnd = (h * 0.98).round();

    var minX = w;
    var minY = h;
    var maxX = 0;
    var maxY = 0;
    var subjectCount = 0;
    var scanned = 0;

    for (var y = yStart; y < yEnd; y++) {
      for (var x = 0; x < w; x++) {
        scanned++;
        if (!_isSubjectPixel(image, x, y, bg)) continue;
        subjectCount++;
        minX = math.min(minX, x);
        minY = math.min(minY, y);
        maxX = math.max(maxX, x);
        maxY = math.max(maxY, y);
      }
    }

    if (subjectCount < scanned * 0.04 || maxX <= minX || maxY <= minY) {
      return const VehiclePhotoDetection(
        bounds: VehiclePhotoBounds(left: 0.08, top: 0.20, width: 0.84, height: 0.58),
        confidence: 0.32,
      );
    }

    final padX = (maxX - minX) * 0.06;
    final padY = (maxY - minY) * 0.08;
    minX = (minX - padX).round().clamp(0, w - 1);
    minY = (minY - padY).round().clamp(0, h - 1);
    maxX = (maxX + padX).round().clamp(minX + 1, w);
    maxY = (maxY + padY).round().clamp(minY + 1, h);

    final bounds = clampBounds(
      VehiclePhotoBounds(
        left: minX / w,
        top: minY / h,
        width: (maxX - minX) / w,
        height: (maxY - minY) / h,
      ),
    );

    final bboxArea = (maxX - minX) * (maxY - minY);
    final fillRatio = subjectCount / bboxArea;
    final coverage = subjectCount / scanned;
    final confidence = (fillRatio * 0.55 + coverage * 4.2).clamp(0.0, 0.96);

    return VehiclePhotoDetection(bounds: bounds, confidence: confidence);
  }

  bool _isSubjectPixel(
    img.Image image,
    int x,
    int y,
    ({int r, int g, int b}) bg,
  ) {
    final pixel = image.getPixel(x, y);
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    final lum = pixelLuminance(pixel);
    final dist = colorDistance(r, g, b, bg.r, bg.g, bg.b);

    // Reject uniform sky in upper frame.
    if (y < image.height * 0.22 && lum > 195 && dist < 2800) return false;
    // Reject pavement-like low-contrast zones.
    if (lum > 215 && dist < 1200) return false;
    // Keep pixels that differ from background or have vehicle-like luminance.
    return dist > 900 || (lum > 35 && lum < 220);
  }

  img.Image _removeBackground(img.Image source) {
    final bg = estimateBackgroundColor(source);
    final out = img.Image(width: source.width, height: source.height, numChannels: 4);
    final threshold = 2200.0;

    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        final pixel = source.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final lum = pixelLuminance(pixel);
        final dist = colorDistance(r, g, b, bg.r, bg.g, bg.b);

        var alpha = 1.0;
        if (dist < threshold) {
          alpha = (dist / threshold).clamp(0.0, 1.0);
        }
        // Soften very bright fringe (sky bleed).
        if (lum > 210 && dist < 4500) alpha *= 0.25;
        // Preserve dark tyres / shadows.
        if (lum < 28) alpha = math.max(alpha, 0.72);

        // Edge feather toward image border.
        final edgeX = math.min(x, source.width - 1 - x) / (source.width * 0.08);
        final edgeY = math.min(y, source.height - 1 - y) / (source.height * 0.08);
        alpha *= math.min(1.0, math.min(edgeX, edgeY));

        final a = (alpha * 255).round().clamp(0, 255);
        out.setPixelRgba(x, y, r, g, b, a);
      }
    }

    return out;
  }
}
