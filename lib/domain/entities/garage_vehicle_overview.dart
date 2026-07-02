import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_health.dart';

/// Aggregated garage row — avoids N+1 provider subscriptions per vehicle card.
class GarageVehicleOverview {
  const GarageVehicleOverview({
    required this.vehicle,
    required this.health,
  });

  final Vehicle vehicle;
  final VehicleHealth health;
}
