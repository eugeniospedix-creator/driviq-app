import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/catalog/vehicle_catalog.dart';
import '../../../domain/entities/vehicle_catalog_entry.dart';

class VehicleIdentitySelection {
  const VehicleIdentitySelection({
    required this.catalogEntry,
    required this.year,
    this.isCustom = false,
  });

  final VehicleCatalogEntry catalogEntry;
  final int year;
  final bool isCustom;
}

class VehicleIdentityPicker extends StatelessWidget {
  const VehicleIdentityPicker({
    super.key,
    required this.selected,
    required this.year,
    required this.onCatalogSelected,
    required this.onYearSelected,
    required this.onCustomTap,
    this.customActive = false,
  });

  final VehicleCatalogEntry? selected;
  final int year;
  final ValueChanged<VehicleCatalogEntry> onCatalogSelected;
  final ValueChanged<int> onYearSelected;
  final VoidCallback onCustomTap;
  final bool customActive;

  static const _years = [2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT YOUR VEHICLE',
          style: TextStyle(
            color: DQ.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: VehicleCatalog.entries.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == VehicleCatalog.entries.length) {
                return _CustomVehicleTile(active: customActive, onTap: onCustomTap);
              }
              final entry = VehicleCatalog.entries[index];
              final active = !customActive && selected?.assetKey == entry.assetKey;
              return _CatalogVehicleTile(
                entry: entry,
                active: active,
                onTap: () => onCatalogSelected(entry),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'MODEL YEAR',
          style: TextStyle(
            color: DQ.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _years.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final value = _years[index];
              final active = year == value;
              return GestureDetector(
                onTap: () => onYearSelected(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? DQ.cyan.withValues(alpha: 0.16) : DQ.graphite3,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: active ? DQ.cyan.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.06),
                    ),
                    boxShadow: active
                        ? [BoxShadow(color: DQ.cyan.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 6))]
                        : null,
                  ),
                  child: Text(
                    '$value',
                    style: TextStyle(
                      color: active ? DQ.textPrimary : DQ.textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatalogVehicleTile extends StatelessWidget {
  const _CatalogVehicleTile({
    required this.entry,
    required this.active,
    required this.onTap,
  });

  final VehicleCatalogEntry entry;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: 148,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: active
                ? [DQ.cyan.withValues(alpha: 0.18), DQ.graphite3]
                : [DQ.graphite3, DQ.graphite2],
          ),
          borderRadius: BorderRadius.circular(DQ.radiusMd),
          border: Border.all(
            color: active ? DQ.cyan.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: active
              ? [BoxShadow(color: DQ.cyan.withValues(alpha: 0.16), blurRadius: 24, offset: const Offset(0, 10))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.make.toUpperCase(),
              style: TextStyle(
                color: active ? DQ.cyan : DQ.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const Spacer(),
            Text(
              entry.model,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DQ.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomVehicleTile extends StatelessWidget {
  const _CustomVehicleTile({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: 118,
        decoration: BoxDecoration(
          color: active ? DQ.cyan.withValues(alpha: 0.1) : DQ.graphite3,
          borderRadius: BorderRadius.circular(DQ.radiusMd),
          border: Border.all(
            color: active ? DQ.cyan.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              color: active ? DQ.cyan : DQ.textMuted,
              size: 26,
            ),
            const SizedBox(height: 10),
            Text(
              'Other',
              style: TextStyle(
                color: active ? DQ.textPrimary : DQ.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
