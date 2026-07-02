import '../../domain/entities/scan_session.dart';
import '../../domain/entities/vehicle_health.dart';
import '../../domain/enums/health_status.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../datasources/local/hive_local_store.dart';
import '../models/scan_session_model.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  DiagnosisRepositoryImpl(this._store);

  final HiveLocalStore _store;

  @override
  Future<ScanSession?> getById(String id) async {
    final raw = _store.scans.get(id);
    if (raw == null) return null;
    return ScanSessionModel.fromJson(Map<dynamic, dynamic>.from(raw as Map)).toEntity();
  }

  @override
  Future<List<ScanSession>> getHistoryForVehicle(String vehicleId) async {
    return _store.scans.values
        .map((s) => ScanSessionModel.fromJson(Map<dynamic, dynamic>.from(s as Map)).toEntity())
        .where((s) => s.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<ScanSession?> getLatestForVehicle(String vehicleId) async {
    final history = await getHistoryForVehicle(vehicleId);
    if (history.isEmpty) return null;
    return history.first;
  }

  @override
  Future<VehicleHealth> getHealthForVehicle(String vehicleId) async {
    final latest = await getLatestForVehicle(vehicleId);
    if (latest == null) {
      return const VehicleHealth(
        score: 0,
        status: HealthStatus.good,
        summary: 'No scan recorded yet. Run your first intelligence scan.',
        lastScanAt: null,
      );
    }

    final history = await getHistoryForVehicle(vehicleId);
    int? trend;
    if (history.length >= 2) {
      trend = latest.healthScore - history[1].healthScore;
    }

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
  }
}
