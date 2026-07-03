import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/vehicle_photo_bounds.dart';

class NativeSegmentationMask {
  const NativeSegmentationMask({
    required this.width,
    required this.height,
    required this.alpha,
    required this.bounds,
    required this.confidence,
  });

  final int width;
  final int height;
  final Uint8List alpha;
  final VehiclePhotoBounds bounds;
  final double confidence;
}

/// On-device foreground segmentation via platform Vision / ML Kit.
class NativeVehicleSegmentation {
  NativeVehicleSegmentation._();

  static const _channel = MethodChannel('com.driviq/vision_segmentation');

  static Future<NativeSegmentationMask?> segment(String imagePath) async {
    if (!Platform.isIOS && !Platform.isAndroid) return null;
    try {
      final result = await _channel.invokeMethod<Object?>('segmentForeground', {
        'path': imagePath,
      });
      if (result is! Map) return null;
      final map = Map<String, dynamic>.from(result);
      final width = (map['width'] as num?)?.toInt();
      final height = (map['height'] as num?)?.toInt();
      final alphaB64 = map['alpha'] as String?;
      if (width == null || height == null || alphaB64 == null) return null;

      final alpha = base64Decode(alphaB64);
      if (alpha.length != width * height) return null;

      return NativeSegmentationMask(
        width: width,
        height: height,
        alpha: Uint8List.fromList(alpha),
        bounds: VehiclePhotoBounds(
          left: (map['left'] as num?)?.toDouble() ?? 0.08,
          top: (map['top'] as num?)?.toDouble() ?? 0.12,
          width: (map['widthNorm'] as num?)?.toDouble() ?? 0.84,
          height: (map['heightNorm'] as num?)?.toDouble() ?? 0.72,
        ),
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.82,
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
