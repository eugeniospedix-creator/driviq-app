import '../enums/vehicle_media_format.dart';
import '../enums/vehicle_studio_role.dart';

class VehicleMediaAsset {
  const VehicleMediaAsset({
    required this.id,
    required this.role,
    required this.format,
    required this.path,
    required this.priority,
    this.status = VehicleMediaStatus.active,
    this.widthPx,
    this.heightPx,
  });

  final String id;
  final VehicleStudioRole role;
  final VehicleMediaFormat format;
  final String path;
  final int priority;
  final VehicleMediaStatus status;
  final int? widthPx;
  final int? heightPx;

  bool get isActive => status == VehicleMediaStatus.active;
}

enum VehicleMediaStatus {
  active,
  optional,
  planned,
}

class VehiclePackIdentity {
  const VehiclePackIdentity({
    required this.make,
    required this.model,
    required this.bodyType,
    required this.fuelTypes,
    this.generation,
    this.yearFrom,
    this.yearTo,
  });

  final String make;
  final String model;
  final String? generation;
  final int? yearFrom;
  final int? yearTo;
  final String bodyType;
  final List<String> fuelTypes;

  bool containsYear(int year) {
    if (yearFrom != null && year < yearFrom!) return false;
    if (yearTo != null && year > yearTo!) return false;
    return true;
  }
}

class VehiclePackStudio {
  const VehiclePackStudio({
    required this.profileId,
    required this.pipelineVersion,
    required this.processedAt,
    required this.sourceType,
    required this.sourceLabel,
    this.fallbackPackId,
  });

  final String profileId;
  final String pipelineVersion;
  final String processedAt;
  final String sourceType;
  final String sourceLabel;
  final String? fallbackPackId;
}

class VehiclePackManifest {
  const VehiclePackManifest({
    required this.packId,
    required this.packVersion,
    required this.identity,
    required this.displayLabel,
    required this.studio,
    required this.media,
    required this.studioProfile,
    this.displaySubtitle,
    this.anchorsRef = 'anchors.json',
    this.preferredPresentation = 'auto',
    this.lifecycleStatus = 'active',
  });

  final String packId;
  final String packVersion;
  final VehiclePackIdentity identity;
  final String displayLabel;
  final String? displaySubtitle;
  final VehiclePackStudio studio;
  final List<VehicleMediaAsset> media;
  final String anchorsRef;
  final String studioProfile;
  final String preferredPresentation;
  final String lifecycleStatus;

  VehicleMediaAsset? mediaForRole(VehicleStudioRole role) {
    final matches = media.where((m) => m.role == role && m.isActive).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    return matches.isEmpty ? null : matches.first;
  }

  List<VehicleMediaAsset> mediaForRoleAllFormats(VehicleStudioRole role) {
    return media
        .where((m) => m.role == role && m.isActive)
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }
}
