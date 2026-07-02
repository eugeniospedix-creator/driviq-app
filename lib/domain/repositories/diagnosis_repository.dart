import '../entities/scan_session.dart';
import '../entities/vehicle_health.dart';

abstract class DiagnosisRepository {
  Future<List<ScanSession>> getHistoryForVehicle(String vehicleId);
  Future<ScanSession?> getLatestForVehicle(String vehicleId);
  Future<ScanSession?> getById(String id);
  Future<VehicleHealth> getHealthForVehicle(String vehicleId);
  Future<void> save(ScanSession session);
}
