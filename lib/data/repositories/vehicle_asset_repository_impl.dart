import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../domain/entities/resolved_vehicle_asset_pack.dart';
import '../../../domain/entities/vehicle_asset_catalog.dart';
import '../../../domain/entities/vehicle_pack_license.dart';
import '../../../domain/entities/vehicle_pack_manifest.dart';
import '../../../domain/enums/vehicle_asset_resolution_kind.dart';
import '../../../domain/enums/vehicle_media_format.dart';
import '../../../domain/enums/vehicle_studio_role.dart';
import '../../../domain/repositories/vehicle_asset_repository.dart';
import '../../data/datasources/local/vehicle_asset_paths.dart';
import '../../../domain/catalog/vehicle_asset_resolver_logic.dart';

class BundledVehicleAssetRepository implements VehicleAssetRepository {
  BundledVehicleAssetRepository();

  VehicleAssetCatalog? _catalog;
  final _manifestCache = <String, VehiclePackManifest>{};
  final _licenseCache = <String, VehiclePackLicense>{};

  @override
  Future<VehicleAssetCatalog> loadCatalog() async {
    if (_catalog != null) return _catalog!;
    final raw = await rootBundle.loadString(VehicleAssetPaths.catalog);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final chainRaw = await rootBundle.loadString(VehicleAssetPaths.fallbackChain);
    final chainJson = jsonDecode(chainRaw) as Map<String, dynamic>;
    final chains = <String, List<String>>{};
    for (final entry in (chainJson['chains'] as Map<String, dynamic>).entries) {
      chains[entry.key] = (entry.value as List).cast<String>();
    }

    final entries = (json['entries'] as List).map((e) {
      final map = e as Map<String, dynamic>;
      final yearRange = map['yearRange'] as Map<String, dynamic>?;
      return VehicleCatalogRecord(
        id: map['id'] as String,
        make: map['make'] as String,
        model: map['model'] as String,
        modelAliases: (map['modelAliases'] as List?)?.cast<String>() ?? const [],
        generation: map['generation'] as String?,
        yearFrom: yearRange?['from'] as int?,
        yearTo: yearRange?['to'] as int?,
        bodyType: map['bodyType'] as String,
        fuelTypes: (map['fuelTypes'] as List).cast<String>(),
        packId: map['packId'] as String,
        matchPriority: map['matchPriority'] as int? ?? 50,
        status: map['status'] as String? ?? 'active',
      );
    }).toList();

    _catalog = VehicleAssetCatalog(
      catalogVersion: json['catalogVersion'] as String,
      studioProfileId: json['studioProfileId'] as String,
      entries: entries,
      fallbackChains: chains,
      universalPackId: chainJson['universal'] as String,
    );
    return _catalog!;
  }

  @override
  Future<VehiclePackManifest> loadPackManifest(String packId) async {
    final cached = _manifestCache[packId];
    if (cached != null) return cached;

    final path = VehicleAssetPaths.packManifest(packId);
    try {
      final raw = await rootBundle.loadString(path);
      final manifest = _parseManifest(packId, jsonDecode(raw) as Map<String, dynamic>);
      _manifestCache[packId] = manifest;
      return manifest;
    } catch (_) {
      final universal = await loadPackManifest(
        _catalog?.universalPackId ?? '_fallback/universal',
      );
      _manifestCache[packId] = universal;
      return universal;
    }
  }

  @override
  Future<VehiclePackLicense> loadPackLicense(String packId) async {
    final cached = _licenseCache[packId];
    if (cached != null) return cached;

    final path = VehicleAssetPaths.packLicense(packId);
    try {
      final raw = await rootBundle.loadString(path);
      final license = _parseLicense(jsonDecode(raw) as Map<String, dynamic>);
      _licenseCache[packId] = license;
      return license;
    } catch (_) {
      const fallback = VehiclePackLicense(
        licenseId: 'drv-lic-fallback-universal',
        licenseType: 'proprietary_in_house',
        commercialUse: true,
        appDistribution: true,
        modification: true,
        attributionRequired: false,
      );
      _licenseCache[packId] = fallback;
      return fallback;
    }
  }

  @override
  Future<ResolvedVehicleAssetPack> resolveForVehicle({
    required String make,
    required String model,
    required int year,
    String? modelAssetKey,
  }) async {
    final catalog = await loadCatalog();
    final match = VehicleAssetResolverLogic.matchCatalogEntry(
      catalog: catalog,
      make: make,
      model: model,
      year: year,
      modelAssetKey: modelAssetKey,
    );

    if (match != null) {
      final manifest = await loadPackManifest(match.packId);
      final license = await loadPackLicense(match.packId);
      final parts = await _resolveManifest(manifest);
      return ResolvedVehicleAssetPack(
        packId: match.packId,
        manifest: parts.manifest,
        license: license,
        resolution: match.resolution,
        bundleRoot: VehicleAssetPaths.bundleRoot,
        mediaPackId: parts.mediaPackId,
        fallbackPackId: manifest.studio.fallbackPackId,
      );
    }

    final bodyType = VehicleAssetResolverLogic.inferBodyType(
      make: make,
      model: model,
      modelAssetKey: modelAssetKey,
    );
    final fallbackPackId = VehicleAssetResolverLogic.resolveFallbackPackId(catalog, bodyType);
    final manifest = await loadPackManifest(fallbackPackId);
    final license = await loadPackLicense(fallbackPackId);
    final parts = await _resolveManifest(manifest);

    return ResolvedVehicleAssetPack(
      packId: fallbackPackId,
      manifest: parts.manifest,
      license: license,
      resolution: fallbackPackId == catalog.universalPackId
          ? VehicleAssetResolutionKind.universal
          : VehicleAssetResolutionKind.bodyFallback,
      bundleRoot: VehicleAssetPaths.bundleRoot,
      mediaPackId: parts.mediaPackId,
    );
  }

  Future<_ResolvedParts> _resolveManifest(VehiclePackManifest manifest) async {
    if (manifest.media.isNotEmpty) {
      final fallbackId = manifest.studio.fallbackPackId;
      if (fallbackId == null) {
        return _ResolvedParts(manifest: manifest, mediaPackId: manifest.packId);
      }
      final fallback = await loadPackManifest(fallbackId);
      final ownRoles = manifest.media.map((m) => m.role).toSet();
      final inherited = fallback.media.where((m) => !ownRoles.contains(m.role)).toList();
      if (inherited.isEmpty) {
        return _ResolvedParts(manifest: manifest, mediaPackId: manifest.packId);
      }
      return _ResolvedParts(
        manifest: VehiclePackManifest(
          packId: manifest.packId,
          packVersion: manifest.packVersion,
          identity: manifest.identity,
          displayLabel: manifest.displayLabel,
          displaySubtitle: manifest.displaySubtitle,
          studio: manifest.studio,
          media: [...manifest.media, ...inherited],
          anchorsRef: manifest.anchorsRef,
          studioProfile: manifest.studioProfile,
          preferredPresentation: manifest.preferredPresentation,
          lifecycleStatus: manifest.lifecycleStatus,
        ),
        mediaPackId: manifest.packId,
      );
    }

    final fallbackId = manifest.studio.fallbackPackId;
    if (fallbackId != null) {
      final fallback = await loadPackManifest(fallbackId);
      return _ResolvedParts(
        manifest: VehiclePackManifest(
          packId: manifest.packId,
          packVersion: manifest.packVersion,
          identity: manifest.identity,
          displayLabel: manifest.displayLabel,
          displaySubtitle: manifest.displaySubtitle,
          studio: manifest.studio,
          media: fallback.media,
          anchorsRef: fallback.anchorsRef,
          studioProfile: fallback.studioProfile,
          preferredPresentation: manifest.preferredPresentation,
          lifecycleStatus: manifest.lifecycleStatus,
        ),
        mediaPackId: fallbackId,
      );
    }

    return _ResolvedParts(manifest: manifest, mediaPackId: manifest.packId);
  }

  VehiclePackManifest _parseManifest(String packId, Map<String, dynamic> json) {
    final identityJson = json['identity'] as Map<String, dynamic>;
    final yearRange = identityJson['yearRange'] as Map<String, dynamic>?;
    final studioJson = json['studio'] as Map<String, dynamic>;
    final displayJson = json['display'] as Map<String, dynamic>;
    final renderingJson = json['rendering'] as Map<String, dynamic>? ?? {};
    final lifecycleJson = json['lifecycle'] as Map<String, dynamic>? ?? {};

    final media = (json['media'] as List? ?? []).map((m) {
      final map = m as Map<String, dynamic>;
      final role = VehicleStudioRole.fromKey(map['role'] as String) ?? VehicleStudioRole.heroHome;
      final format = VehicleMediaFormat.fromKey(map['format'] as String) ?? VehicleMediaFormat.png;
      final statusKey = map['status'] as String? ?? 'active';
      return VehicleMediaAsset(
        id: map['id'] as String,
        role: role,
        format: format,
        path: map['path'] as String,
        priority: map['priority'] as int? ?? 50,
        status: switch (statusKey) {
          'optional' => VehicleMediaStatus.optional,
          'planned' => VehicleMediaStatus.planned,
          _ => VehicleMediaStatus.active,
        },
        widthPx: map['widthPx'] as int?,
        heightPx: map['heightPx'] as int?,
      );
    }).toList();

    return VehiclePackManifest(
      packId: json['packId'] as String? ?? packId,
      packVersion: json['packVersion'] as String? ?? '1.0.0',
      identity: VehiclePackIdentity(
        make: identityJson['make'] as String,
        model: identityJson['model'] as String,
        generation: identityJson['generation'] as String?,
        yearFrom: yearRange?['from'] as int?,
        yearTo: yearRange?['to'] as int?,
        bodyType: identityJson['bodyType'] as String,
        fuelTypes: (identityJson['fuelTypes'] as List?)?.cast<String>() ?? const [],
      ),
      displayLabel: displayJson['label'] as String,
      displaySubtitle: displayJson['subtitle'] as String?,
      studio: VehiclePackStudio(
        profileId: studioJson['profileId'] as String,
        pipelineVersion: studioJson['pipelineVersion'] as String? ?? '1.0.0',
        processedAt: studioJson['processedAt'] as String? ?? '',
        sourceType: studioJson['sourceType'] as String? ?? 'driviq_studio',
        sourceLabel: studioJson['sourceLabel'] as String? ?? 'Driviq Studio Pipeline',
        fallbackPackId: studioJson['fallbackPackId'] as String?,
      ),
      media: media,
      anchorsRef: renderingJson['anchorsRef'] as String? ?? 'anchors.json',
      studioProfile: renderingJson['studioProfile'] as String? ?? 'driviq_dark_studio_v1',
      preferredPresentation: renderingJson['preferredPresentation'] as String? ?? 'auto',
      lifecycleStatus: lifecycleJson['status'] as String? ?? 'active',
    );
  }

  VehiclePackLicense _parseLicense(Map<String, dynamic> json) {
    final rights = json['rights'] as Map<String, dynamic>? ?? {};
    final attribution = json['attribution'] as Map<String, dynamic>? ?? {};
    final acquisition = json['acquisition'] as Map<String, dynamic>? ?? {};

    return VehiclePackLicense(
      licenseId: json['licenseId'] as String? ?? 'unknown',
      licenseType: json['licenseType'] as String? ?? 'unknown',
      commercialUse: rights['commercialUse'] as bool? ?? false,
      appDistribution: rights['appDistribution'] as bool? ?? false,
      modification: rights['modification'] as bool? ?? false,
      attributionRequired: attribution['required'] as bool? ?? false,
      attributionText: attribution['displayText'] as String?,
      attributionUrl: attribution['url'] as String?,
      acquisitionMethod: acquisition['method'] as String?,
      acquisitionDate: acquisition['date'] as String?,
    );
  }
}

class _ResolvedParts {
  const _ResolvedParts({required this.manifest, required this.mediaPackId});

  final VehiclePackManifest manifest;
  final String mediaPackId;
}
