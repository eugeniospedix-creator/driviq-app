import '../enums/health_status.dart';

class VehicleHealth {
  const VehicleHealth({
    required this.score,
    required this.status,
    required this.summary,
    required this.lastScanAt,
    this.trendDelta,
  });

  final int score;
  final HealthStatus status;
  final String summary;
  final DateTime? lastScanAt;

  /// Change since previous scan (+/- points).
  final int? trendDelta;
}
