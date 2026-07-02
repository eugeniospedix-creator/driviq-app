import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/garage_vehicle_overview.dart';
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

/// Single fetch for garage — avoids N+1 health provider subscriptions.
final garageOverviewProvider = FutureProvider<List<GarageVehicleOverview>>((ref) async {
  final vehicles = await ref.watch(vehicleRepositoryProvider).getAll();
  final diagnosis = ref.watch(diagnosisRepositoryProvider);

  final overviews = <GarageVehicleOverview>[];
  for (final vehicle in vehicles) {
    final health = await diagnosis.getHealthForVehicle(vehicle.id);
    overviews.add(GarageVehicleOverview(vehicle: vehicle, health: health));
  }
  return overviews;
});

final selectedFaultIdProvider = StateProvider<String?>((ref) => null);
