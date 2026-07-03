import 'package:image/image.dart' as img;

import '../../domain/entities/vehicle_photo_bounds.dart';
import 'vehicle_photo_image_utils.dart';

enum VehiclePhotoQualityIssue {
  tooDark,
  tooBlurry,
  subjectTooSmall,
  cutoutTooSmall,
  cutoutTouchesEdges,
  lowConfidence,
}

class VehiclePhotoQualityReport {
  const VehiclePhotoQualityReport({required this.ok, this.issues = const []});

  final bool ok;
  final List<VehiclePhotoQualityIssue> issues;

  String? get userMessage {
    if (ok) return null;
    if (issues.contains(VehiclePhotoQualityIssue.tooDark)) {
      return 'Photo is too dark. Use daylight or move to a brighter spot.';
    }
    if (issues.contains(VehiclePhotoQualityIssue.tooBlurry)) {
      return 'Photo looks blurry. Hold steady and retake a sharper shot.';
    }
    if (issues.contains(VehiclePhotoQualityIssue.subjectTooSmall)) {
      return 'Car is too small in frame. Move closer or include the full vehicle.';
    }
    if (issues.contains(VehiclePhotoQualityIssue.cutoutTooSmall)) {
      return 'Could not isolate your vehicle cleanly. Try manual crop.';
    }
    if (issues.contains(VehiclePhotoQualityIssue.cutoutTouchesEdges)) {
      return 'Vehicle is clipped at the edges. Include the full car with margin.';
    }
    return 'Photo quality is not good enough. Retake or adjust crop.';
  }
}

VehiclePhotoQualityReport assessSourceImage(img.Image image) {
  final issues = <VehiclePhotoQualityIssue>[];
  if (_averageLuminance(image) < 42) issues.add(VehiclePhotoQualityIssue.tooDark);
  if (_blurScore(image) < 18) issues.add(VehiclePhotoQualityIssue.tooBlurry);
  return VehiclePhotoQualityReport(ok: issues.isEmpty, issues: issues);
}

VehiclePhotoQualityReport assessBoundsCoverage(
  VehiclePhotoBounds bounds, {
  double minCoverage = 0.28,
}) {
  if (bounds.width * bounds.height < minCoverage) {
    return const VehiclePhotoQualityReport(
      ok: false,
      issues: [VehiclePhotoQualityIssue.subjectTooSmall],
    );
  }
  return const VehiclePhotoQualityReport(ok: true);
}

VehiclePhotoQualityReport assessCutout(img.Image cutout, {required double confidence}) {
  final issues = <VehiclePhotoQualityIssue>[];
  if (confidence < 0.48) issues.add(VehiclePhotoQualityIssue.lowConfidence);

  var opaque = 0;
  var edgeHits = 0;
  var left = false, right = false, top = false, bottom = false;

  for (var y = 0; y < cutout.height; y++) {
    for (var x = 0; x < cutout.width; x++) {
      if (cutout.getPixel(x, y).a < 24) continue;
      opaque++;
      if (x <= 2) left = true;
      if (x >= cutout.width - 3) right = true;
      if (y <= 2) top = true;
      if (y >= cutout.height - 3) bottom = true;
    }
  }

  if (opaque / (cutout.width * cutout.height) < 0.12) {
    issues.add(VehiclePhotoQualityIssue.cutoutTooSmall);
  }
  if (left) edgeHits++;
  if (right) edgeHits++;
  if (top) edgeHits++;
  if (bottom) edgeHits++;
  if (edgeHits >= 3) issues.add(VehiclePhotoQualityIssue.cutoutTouchesEdges);

  return VehiclePhotoQualityReport(ok: issues.isEmpty, issues: issues);
}

double _averageLuminance(img.Image image) {
  var sum = 0.0;
  var n = 0;
  final stepX = (image.width / 24).ceil().clamp(1, image.width);
  final stepY = (image.height / 24).ceil().clamp(1, image.height);
  for (var y = 0; y < image.height; y += stepY) {
    for (var x = 0; x < image.width; x += stepX) {
      sum += pixelLuminance(image.getPixel(x, y));
      n++;
    }
  }
  return n == 0 ? 0 : sum / n;
}

double _blurScore(img.Image image) {
  var sum = 0.0;
  var n = 0;
  final step = (image.width / 20).ceil().clamp(2, image.width);
  for (var y = 1; y < image.height - 1; y += step) {
    for (var x = 1; x < image.width - 1; x += step) {
      final c = pixelLuminance(image.getPixel(x, y));
      sum += (c - pixelLuminance(image.getPixel(x + 1, y))).abs();
      sum += (c - pixelLuminance(image.getPixel(x, y + 1))).abs();
      n++;
    }
  }
  return n == 0 ? 0 : sum / n;
}
