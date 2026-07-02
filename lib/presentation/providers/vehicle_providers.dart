import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/scan_session.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_health.dart';
import 'repository_providers.dart';

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  return ref.watch(vehicleRepositoryProvider).getAll();
});

final primaryVehicleProvider = FutureProvider<Vehicle?>((ref) async {
  return ref.watch(vehicleRepositoryProvider).getPrimary();
});

final vehicleHealthProvider = FutureProvider.family<VehicleHealth, String>((ref, vehicleId) async {
  return ref.watch(diagnosisRepositoryProvider).getHealthForVehicle(vehicleId);
});

final latestScanProvider = FutureProvider.family<ScanSession?, String>((ref, vehicleId) async {
  return ref.watch(diagnosisRepositoryProvider).getLatestForVehicle(vehicleId);
});

final scanHistoryProvider = FutureProvider.family<List<ScanSession>, String>((ref, vehicleId) async {
  return ref.watch(diagnosisRepositoryProvider).getHistoryForVehicle(vehicleId);
});

final activeScanSessionProvider = StateProvider<ScanSession?>((ref) => null);

final selectedFaultIdProvider = StateProvider<String?>((ref) => null);
