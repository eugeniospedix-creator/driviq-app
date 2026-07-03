import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/repositories/vehicle_photo_repository.dart';

class VehiclePhotoRepositoryImpl implements VehiclePhotoRepository {
  static const _subdir = 'vehicle_photos';

  @override
  String processedPhotoPath(String vehicleId) {
    // Resolved at save time; this is the predictable filename only.
    return '$vehicleId.png';
  }

  Future<Directory> _photosDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/$_subdir');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<String> saveOriginalFromPath({
    required String vehicleId,
    required String sourcePath,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Source image not found');
    }
    final dir = await _photosDir();
    final ext = _extensionFor(sourcePath);
    final file = File('${dir.path}/${vehicleId}_original$ext');
    await source.copy(file.path);
    return file.path;
  }

  String _extensionFor(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '.jpg';
    final ext = path.substring(dot).toLowerCase();
    if (ext == '.png' || ext == '.jpg' || ext == '.jpeg' || ext == '.heic' || ext == '.webp') {
      return ext == '.jpeg' ? '.jpg' : ext;
    }
    return '.jpg';
  }

  @override
  Future<String> saveProcessedPng({
    required String vehicleId,
    required List<int> pngBytes,
  }) async {
    final dir = await _photosDir();
    final file = File('${dir.path}/$vehicleId.png');
    await file.writeAsBytes(pngBytes, flush: true);
    return file.path;
  }

  @override
  Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> fileExists(String path) => File(path).exists();
}
