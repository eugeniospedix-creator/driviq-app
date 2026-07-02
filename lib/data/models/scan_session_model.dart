import '../../domain/entities/scan_session.dart';
import '../../domain/enums/health_status.dart';
import '../../domain/enums/scan_source.dart';
import 'component_fault_model.dart';

class ScanSessionModel {
  const ScanSessionModel({
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
  final String startedAt;
  final String? completedAt;
  final int healthScore;
  final String healthStatus;
  final String? summary;
  final List<ComponentFaultModel> faults;
  final List<String> sources;

  factory ScanSessionModel.fromEntity(ScanSession entity) => ScanSessionModel(
        id: entity.id,
        vehicleId: entity.vehicleId,
        startedAt: entity.startedAt.toIso8601String(),
        completedAt: entity.completedAt?.toIso8601String(),
        healthScore: entity.healthScore,
        healthStatus: entity.healthStatus.name,
        summary: entity.summary,
        faults: entity.faults.map(ComponentFaultModel.fromEntity).toList(),
        sources: entity.sources.map((s) => s.name).toList(),
      );

  ScanSession toEntity() => ScanSession(
        id: id,
        vehicleId: vehicleId,
        startedAt: DateTime.parse(startedAt),
        completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
        healthScore: healthScore,
        healthStatus: HealthStatus.values.byName(healthStatus),
        summary: summary,
        faults: faults.map((f) => f.toEntity()).toList(),
        sources: sources.map((s) => ScanSource.values.byName(s)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'startedAt': startedAt,
        'completedAt': completedAt,
        'healthScore': healthScore,
        'healthStatus': healthStatus,
        'summary': summary,
        'faults': faults.map((f) => f.toJson()).toList(),
        'sources': sources,
      };

  factory ScanSessionModel.fromJson(Map<dynamic, dynamic> json) => ScanSessionModel(
        id: json['id'] as String,
        vehicleId: json['vehicleId'] as String,
        startedAt: json['startedAt'] as String,
        completedAt: json['completedAt'] as String?,
        healthScore: json['healthScore'] as int,
        healthStatus: json['healthStatus'] as String,
        summary: json['summary'] as String?,
        faults: (json['faults'] as List)
            .map((f) => ComponentFaultModel.fromJson(Map<dynamic, dynamic>.from(f as Map)))
            .toList(),
        sources: (json['sources'] as List).cast<String>(),
      );
}
