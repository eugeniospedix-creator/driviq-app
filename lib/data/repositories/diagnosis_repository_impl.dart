import '../../domain/entities/scan_session.dart';
import '../../domain/entities/vehicle_health.dart';
import '../../domain/enums/health_status.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../datasources/local/hive_local_store.dart';
import '../models/scan_session_model.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  DiagnosisRepositoryImpl(this._store);

  final HiveLocalStore _store;

  static String _latestScanKey(String vehicleId) => 'latest_scan_$vehicleId';

  ScanSession? _parseSession(dynamic raw) {
    if (raw is! Map) return null;
    try {
      return ScanSessionModel.fromJson(Map<dynamic, dynamic>.from(raw)).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ScanSession?> getById(String id) async {
    return _parseSession(_store.scans.get(id));
  }

  @override
  Future<List<ScanSession>> getHistoryForVehicle(String vehicleId) async {
    final sessions = <ScanSession>[];
    for (final raw in _store.scans.values) {
      final session = _parseSession(raw);
      if (session != null && session.vehicleId == vehicleId) {
        sessions.add(session);
      }
    }
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  @override
  Future<ScanSession?> getLatestForVehicle(String vehicleId) async {
    final indexedId = _store.meta.get(_latestScanKey(vehicleId));
    if (indexedId is String) {
      final indexed = await getById(indexedId);
      if (indexed != null) return indexed;
    }

    final history = await getHistoryForVehicle(vehicleId);
    if (history.isEmpty) return null;

    final latest = history.first;
    await _store.meta.put(_latestScanKey(vehicleId), latest.id);
    return latest;
  }

  @override
  Future<VehicleHealth> getHealthForVehicle(String vehicleId) async {
    final history = await getHistoryForVehicle(vehicleId);
    if (history.isEmpty) {
      return const VehicleHealth(
        score: 0,
        status: HealthStatus.good,
        summary: 'No scan recorded yet. Run your first intelligence scan.',
        lastScanAt: null,
      );
    }

    final latest = history.first;
    final trend = history.length >= 2 ? latest.healthScore - history[1].healthScore : null;

    return VehicleHealth(
      score: latest.healthScore,
      status: latest.healthStatus,
      summary: latest.summary ?? 'Analysis complete.',
      lastScanAt: latest.completedAt ?? latest.startedAt,
      trendDelta: trend,
    );
  }

  @override
  Future<void> save(ScanSession session) async {
    await _store.scans.put(session.id, ScanSessionModel.fromEntity(session).toJson());
    await _store.meta.put(_latestScanKey(session.vehicleId), session.id);
  }
}
