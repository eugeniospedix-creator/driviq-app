import '../entities/vehicle_asset_catalog.dart';
import '../enums/vehicle_asset_resolution_kind.dart';

class VehicleCatalogMatch {
  const VehicleCatalogMatch({
    required this.packId,
    required this.resolution,
    required this.bodyType,
  });

  final String packId;
  final VehicleAssetResolutionKind resolution;
  final String bodyType;
}

/// Pure catalog matching — no I/O, no Flutter.
abstract final class VehicleAssetResolverLogic {
  static final _assetKeyToPackId = {
    'bmw_m340i': 'bmw/g20-m340i',
    'bmw_m3': 'bmw/g80-m3',
    'tesla_model_3': 'tesla/model-3',
    'audi_a3': 'audi/8y-a3',
    'audi_a4': 'audi/b9-a4',
    'toyota_corolla': 'toyota/e210-corolla',
  };

  static VehicleCatalogMatch? matchCatalogEntry({
    required VehicleAssetCatalog catalog,
    required String make,
    required String model,
    required int year,
    String? modelAssetKey,
  }) {
    if (modelAssetKey != null) {
      final packFromKey = _assetKeyToPackId[modelAssetKey];
      if (packFromKey != null) {
        final record = catalog.entries.where((e) => e.packId == packFromKey).firstOrNull;
        if (record != null) {
          return VehicleCatalogMatch(
            packId: record.packId,
            resolution: VehicleAssetResolutionKind.exact,
            bodyType: record.bodyType,
          );
        }
      }
    }

    final normalizedMake = _normalize(make);
    final normalizedModel = _normalize(model);

    VehicleCatalogRecord? best;
    var bestScore = -1;

    for (final entry in catalog.activeEntries()) {
      final score = _matchScore(
        entry: entry,
        normalizedMake: normalizedMake,
        normalizedModel: normalizedModel,
        year: year,
      );
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }

    if (best == null || bestScore < 40) return null;

    final resolution = best.matchesYear(year)
        ? VehicleAssetResolutionKind.exact
        : VehicleAssetResolutionKind.model;

    return VehicleCatalogMatch(
      packId: best.packId,
      resolution: resolution,
      bodyType: best.bodyType,
    );
  }

  static int _matchScore({
    required VehicleCatalogRecord entry,
    required String normalizedMake,
    required String normalizedModel,
    required int year,
  }) {
    final entryMake = _normalize(entry.make);
    if (normalizedMake != entryMake && !normalizedMake.contains(entryMake) && !entryMake.contains(normalizedMake)) {
      return 0;
    }

    var score = 30 + entry.matchPriority;

    final entryModel = _normalize(entry.model);
    final modelTokens = entryModel.split(' ');
    final firstToken = modelTokens.first;

    if (normalizedModel == entryModel) {
      score += 80;
    } else if (normalizedModel.contains(entryModel) || entryModel.contains(normalizedModel)) {
      score += 60;
    } else if (normalizedModel.contains(firstToken)) {
      score += 45;
    } else {
      for (final alias in entry.modelAliases) {
        final aliasNorm = _normalize(alias);
        if (normalizedModel.contains(aliasNorm) || aliasNorm.contains(normalizedModel)) {
          score += 50;
          break;
        }
      }
    }

    if (entry.matchesYear(year)) {
      score += 25;
    }

    return score;
  }

  static String inferBodyType({
    required String make,
    required String model,
    String? modelAssetKey,
  }) {
    if (modelAssetKey != null) {
      final packId = _assetKeyToPackId[modelAssetKey];
      if (packId != null) {
        if (packId.contains('tesla')) return 'ev_sedan';
        if (packId.contains('a4')) return 'executive_sedan';
        if (packId.contains('a3') || packId.contains('corolla')) return 'compact_sedan';
        if (packId.contains('bmw')) return 'sport_sedan';
      }
    }

    final makeL = make.toLowerCase();
    final modelL = model.toLowerCase();

    if (makeL.contains('tesla') || makeL.contains('rivian') || makeL.contains('lucid')) {
      return 'ev_sedan';
    }
    if (makeL.contains('bmw')) return 'sport_sedan';
    if (makeL.contains('toyota')) return 'compact_sedan';
    if (makeL.contains('audi')) {
      if (modelL.contains('a4') || modelL.contains('a6') || modelL.contains('a8')) {
        return 'executive_sedan';
      }
      return 'compact_sedan';
    }

    return 'sport_sedan';
  }

  static String resolveFallbackPackId(VehicleAssetCatalog catalog, String bodyType) {
    final chain = catalog.fallbackChains[bodyType];
    if (chain != null && chain.isNotEmpty) return chain.first;
    return catalog.universalPackId;
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
