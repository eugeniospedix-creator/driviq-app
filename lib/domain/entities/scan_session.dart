import '../enums/health_status.dart';
import '../enums/scan_source.dart';
import 'component_fault.dart';

class ScanSession {
  const ScanSession({
    required this.id,
    required this.vehicleId,
    required this.startedAt,
    required this.healthScore,
    required this.healthStatus,
    required this.faults,
    required this.sources,
    this.completedAt,
    this.summary,
  });

  final String id;
  final String vehicleId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int healthScore;
  final HealthStatus healthStatus;
  final String? summary;
  final List<ComponentFault> faults;
  final List<ScanSource> sources;

  bool get isComplete => completedAt != null;

  Duration get duration => (completedAt ?? DateTime.now()).difference(startedAt);
}
