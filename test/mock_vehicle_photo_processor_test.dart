import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:driviq/domain/entities/vehicle_photo_bounds.dart';
import 'package:driviq/domain/repositories/vehicle_photo_repository.dart';
import 'package:driviq/services/vehicle_photo/ai_vehicle_photo_processor.dart';

class _TempPhotoRepository implements VehiclePhotoRepository {
  _TempPhotoRepository(this.dir);

  final Directory dir;

  @override
  Future<void> deleteIfExists(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<bool> fileExists(String path) => File(path).exists();

  @override
  String processedPhotoPath(String vehicleId) => '${dir.path}/$vehicleId.png';

  @override
  Future<String> saveOriginalFromPath({
    required String vehicleId,
    required String sourcePath,
  }) async {
    final file = File('${dir.path}/${vehicleId}_original.jpg');
    await File(sourcePath).copy(file.path);
    return file.path;
  }

  @override
  Future<String> saveProcessedPng({
    required String vehicleId,
    required List<int> pngBytes,
  }) async {
    final file = File(processedPhotoPath(vehicleId));
    await file.writeAsBytes(pngBytes, flush: true);
    return file.path;
  }
}

img.Image _testCarImage() {
  final source = img.Image(width: 800, height: 600, numChannels: 3);
  for (var y = 0; y < 600; y++) {
    for (var x = 0; x < 800; x++) {
      final stripe = (x ~/ 2) % 2 == 0 ? 14 : -10;
      final grain = ((x * 17 + y * 31) % 23) - 11;
      final base = 178 + stripe + grain + (y % 7);
      source.setPixelRgba(x, y, base, base + 8, base + 16, 255);
    }
  }
  for (var y = 220; y < 420; y++) {
    for (var x = 120; x < 680; x++) {
      final shade = 34 + ((x + y) % 7) * 5;
      source.setPixelRgba(x, y, shade, shade + 6, shade + 12, 255);
    }
  }
  return source;
}

void main() {
  test('AI processor detects subject and writes transparent PNG cutout', () async {
    final tempDir = Directory.systemTemp.createTempSync('driviq_photo_test');
    final repo = _TempPhotoRepository(tempDir);
    final processor = AiVehiclePhotoProcessor(repo);

    final sourcePath = '${tempDir.path}/source.jpg';
    await File(sourcePath).writeAsBytes(img.encodeJpg(_testCarImage()));

    final detection = await processor.analyze(sourceImagePath: sourcePath);
    expect(detection.confidence, greaterThan(0.5));
    expect(detection.bounds.width, greaterThan(0.3));

    final result = await processor.process(
      sourceImagePath: sourcePath,
      vehicleId: 'test_vehicle',
      cropBounds: detection.bounds,
    );

    expect(result.localPath, isNotEmpty);
    expect(await File(result.localPath).exists(), isTrue);

    final out = img.decodePng(await File(result.localPath).readAsBytes());
    expect(out, isNotNull);
    expect(out!.hasAlpha, isTrue);

    await tempDir.delete(recursive: true);
  });

  test('manual crop bounds are respected', () async {
    final tempDir = Directory.systemTemp.createTempSync('driviq_photo_test');
    final repo = _TempPhotoRepository(tempDir);
    final processor = AiVehiclePhotoProcessor(repo);

    final sourcePath = '${tempDir.path}/source.jpg';
    await File(sourcePath).writeAsBytes(img.encodeJpg(_testCarImage()));

    const manual = VehiclePhotoBounds(left: 0.15, top: 0.30, width: 0.70, height: 0.40);
    final result = await processor.process(
      sourceImagePath: sourcePath,
      vehicleId: 'manual_crop',
      cropBounds: manual,
    );

    expect(result.bounds?.left, manual.left);
    expect(await File(result.localPath).exists(), isTrue);

    await tempDir.delete(recursive: true);
  });
}
