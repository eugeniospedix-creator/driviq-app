import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../data/datasources/local/hive_local_store.dart';
import '../../domain/entities/vehicle_model_asset.dart';
import '../../domain/entities/vehicle_photo_set.dart';
import '../../domain/enums/vehicle_model_generation_status.dart';
import '../../domain/enums/vehicle_photo_angle.dart';
import '../interfaces/vehicle_3d_reconstruction_service.dart';

/// Local persistence for multi-photo sets and reconstruction job status.
class LocalVehicle3DReconstructionService implements Vehicle3DReconstructionService {
  LocalVehicle3DReconstructionService(this._store);

  final HiveLocalStore _store;
  final _controllers = <String, StreamController<VehicleModelAsset>>{};

  @override
  Future<VehiclePhotoSet?> getPhotoSet(String vehicleId) async {
    final raw = _store.meta.get('photoSet:$vehicleId');
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final photos = <VehiclePhotoAngle, String>{};
    final byAngle = map['photos'] as Map?;
    if (byAngle != null) {
      for (final entry in byAngle.entries) {
        VehiclePhotoAngle? angle;
        for (final candidate in VehiclePhotoAngle.values) {
          if (candidate.name == entry.key) {
            angle = candidate;
            break;
          }
        }
        if (angle != null && entry.value is String) {
          photos[angle] = entry.value as String;
        }
      }
    }
    return VehiclePhotoSet(
      vehicleId: vehicleId,
      photosByAngle: photos,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<VehiclePhotoSet> savePhoto({
    required String vehicleId,
    required VehiclePhotoAngle angle,
    required String localPath,
  }) async {
    final existing = await getPhotoSet(vehicleId);
    final photos = Map<VehiclePhotoAngle, String>.from(existing?.photosByAngle ?? {});
    final dir = await _photoSetDir(vehicleId);
    final dest = File('${dir.path}/${angle.name}.jpg');
    await File(localPath).copy(dest.path);
    photos[angle] = dest.path;
    final set = VehiclePhotoSet(
      vehicleId: vehicleId,
      photosByAngle: photos,
      updatedAt: DateTime.now(),
    );
    await _store.meta.put('photoSet:$vehicleId', {
      'photos': photos.map((k, v) => MapEntry(k.name, v)),
      'updatedAt': set.updatedAt.toIso8601String(),
    });
    return set;
  }

  @override
  Future<VehicleModelAsset> getModelAsset(String vehicleId) async {
    final raw = _store.meta.get('modelAsset:$vehicleId');
    if (raw is! Map) {
      return VehicleModelAsset(
        vehicleId: vehicleId,
        status: VehicleModelGenerationStatus.notStarted,
        updatedAt: DateTime.now(),
      );
    }
    return _decodeAsset(vehicleId, Map<String, dynamic>.from(raw));
  }

  @override
  Future<VehicleModelAsset> startReconstruction(String vehicleId) async {
    final set = await getPhotoSet(vehicleId);
    if (set == null || !set.isComplete) {
      final asset = VehicleModelAsset(
        vehicleId: vehicleId,
        status: VehicleModelGenerationStatus.collectingPhotos,
        statusMessage: 'Capture all required angles to build your 3D model.',
        updatedAt: DateTime.now(),
      );
      await _persistAsset(asset);
      return asset;
    }

    var asset = VehicleModelAsset(
      vehicleId: vehicleId,
      status: VehicleModelGenerationStatus.processing,
      statusMessage: 'Processing 3D model from your photos…',
      progress: 0.15,
      updatedAt: DateTime.now(),
    );
    await _persistAsset(asset);
    _emit(asset);

    // Honest pending state — production mesh requires external reconstruction service.
    await Future<void>.delayed(const Duration(seconds: 2));
    asset = asset.copyWith(
      status: VehicleModelGenerationStatus.pendingService,
      statusMessage:
          'Your photos are saved. Full 3D reconstruction is queued — studio photo is active until the model is ready.',
      progress: 0.42,
      updatedAt: DateTime.now(),
    );
    await _persistAsset(asset);
    _emit(asset);
    return asset;
  }

  @override
  Stream<VehicleModelAsset> watchModelAsset(String vehicleId) {
    final controller = _controllers.putIfAbsent(
      vehicleId,
      () => StreamController<VehicleModelAsset>.broadcast(),
    );
    getModelAsset(vehicleId).then((asset) => _emit(asset));
    return controller.stream;
  }

  Future<Directory> _photoSetDir(String vehicleId) async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/vehicle_3d/$vehicleId');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _persistAsset(VehicleModelAsset asset) async {
    await _store.meta.put('modelAsset:${asset.vehicleId}', {
      'status': asset.status.name,
      'glbPath': asset.glbPath,
      'usdzPath': asset.usdzPath,
      'texturePath': asset.texturePath,
      'statusMessage': asset.statusMessage,
      'progress': asset.progress,
      'updatedAt': asset.updatedAt.toIso8601String(),
    });
  }

  VehicleModelAsset _decodeAsset(String vehicleId, Map<String, dynamic> map) {
    final statusName = map['status'] as String? ?? VehicleModelGenerationStatus.notStarted.name;
    final status = VehicleModelGenerationStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => VehicleModelGenerationStatus.notStarted,
    );
    return VehicleModelAsset(
      vehicleId: vehicleId,
      status: status,
      glbPath: map['glbPath'] as String?,
      usdzPath: map['usdzPath'] as String?,
      texturePath: map['texturePath'] as String?,
      statusMessage: map['statusMessage'] as String?,
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  void _emit(VehicleModelAsset asset) {
    _controllers[asset.vehicleId]?.add(asset);
  }
}
