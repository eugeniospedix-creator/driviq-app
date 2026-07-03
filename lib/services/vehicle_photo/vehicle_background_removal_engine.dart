import 'dart:math' as math;

import 'package:image/image.dart' as img;

import '../../domain/entities/vehicle_photo_bounds.dart';
import 'native_vehicle_segmentation.dart';
import 'vehicle_photo_image_utils.dart';

/// Professional vehicle cutout pipeline — native mask when available, refined matte fallback.
class VehicleBackgroundRemovalEngine {
  const VehicleBackgroundRemovalEngine();

  Future<({img.Image cutout, double confidence})> removeBackground({
    required img.Image source,
    String? sourcePath,
  }) async {
    if (sourcePath != null) {
      final mask = await NativeVehicleSegmentation.segment(sourcePath);
      if (mask != null && mask.confidence >= 0.55) {
        final cutout = applyAlphaMask(source, mask);
        final refined = refineMatteEdges(cutout);
        return (cutout: refined, confidence: mask.confidence);
      }
    }

    final heuristic = removeBackgroundPremium(source);
    final refined = refineMatteEdges(heuristic);
    return (cutout: refined, confidence: 0.62);
  }

  img.Image applyAlphaMask(img.Image source, NativeSegmentationMask mask) {
    final scaleX = source.width / mask.width;
    final scaleY = source.height / mask.height;
    final out = img.Image(width: source.width, height: source.height, numChannels: 4);

    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        final mx = (x / scaleX).floor().clamp(0, mask.width - 1);
        final my = (y / scaleY).floor().clamp(0, mask.height - 1);
        final alpha = mask.alpha[my * mask.width + mx];
        final p = source.getPixel(x, y);
        out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), alpha);
      }
    }
    return out;
  }

  /// Edge-preserving matte cleanup — protects wheels, mirrors, roof line.
  img.Image refineMatteEdges(img.Image source) {
    final w = source.width;
    final h = source.height;
    final out = img.Image.from(source);

    // Close small background holes inside the vehicle silhouette.
    for (var pass = 0; pass < 2; pass++) {
      for (var y = 1; y < h - 1; y++) {
        for (var x = 1; x < w - 1; x++) {
          final center = source.getPixel(x, y).a;
          if (center >= 40) continue;
          var neighbors = 0;
          for (var dy = -1; dy <= 1; dy++) {
            for (var dx = -1; dx <= 1; dx++) {
              if (source.getPixel(x + dx, y + dy).a >= 180) neighbors++;
            }
          }
          if (neighbors >= 6) {
            final p = source.getPixel(x, y);
            out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 220);
          }
        }
      }
    }

    // Feather only border pixels — keeps hard vehicle core intact.
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final a = out.getPixel(x, y).a.toInt();
        if (a == 0 || a == 255) continue;
        var edge = false;
        for (final (dx, dy) in [(0, -1), (0, 1), (-1, 0), (1, 0)]) {
          final nx = x + dx;
          final ny = y + dy;
          if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
          final na = out.getPixel(nx, ny).a;
          if ((na - a).abs() > 80) {
            edge = true;
            break;
          }
        }
        if (edge) {
          final p = out.getPixel(x, y);
          final feathered = (a * 0.88 + 32).round().clamp(0, 255);
          out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), feathered);
        }
      }
    }

    return out;
  }

  VehiclePhotoBounds boundsFromAlpha(img.Image cutout) {
    var minX = cutout.width;
    var minY = cutout.height;
    var maxX = 0;
    var maxY = 0;
    var count = 0;

    for (var y = 0; y < cutout.height; y++) {
      for (var x = 0; x < cutout.width; x++) {
        if (cutout.getPixel(x, y).a < 48) continue;
        count++;
        minX = math.min(minX, x);
        minY = math.min(minY, y);
        maxX = math.max(maxX, x);
        maxY = math.max(maxY, y);
      }
    }

    if (count < 32 || maxX <= minX) {
      return const VehiclePhotoBounds(left: 0.08, top: 0.12, width: 0.84, height: 0.72);
    }

    return clampBounds(
      VehiclePhotoBounds(
        left: minX / cutout.width,
        top: minY / cutout.height,
        width: (maxX - minX) / cutout.width,
        height: (maxY - minY) / cutout.height,
      ),
    );
  }
}
