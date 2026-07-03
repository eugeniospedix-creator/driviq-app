import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/vehicle_health.dart';
import '../../../domain/enums/driviq_weather_mood.dart';
import '../health/health_ring.dart';
import '../vehicle/vehicle_hero_stage.dart';

class VehicleGarageCard extends StatelessWidget {
  const VehicleGarageCard({
    super.key,
    required this.vehicle,
    required this.health,
    required this.onTap,
    this.isPrimary = false,
    this.onPhotoTap,
    this.mood,
    this.weatherEffectsEnabled = false,
  });

  final Vehicle vehicle;
  final VehicleHealth health;
  final VoidCallback onTap;
  final bool isPrimary;
  final VoidCallback? onPhotoTap;
  final DriviqWeatherMood? mood;
  final bool weatherEffectsEnabled;

  @override
  Widget build(BuildContext context) {
    final color = DQ.healthColor(health.score);
    final lastScan = health.lastScanAt != null
        ? DateFormat.MMMd().format(health.lastScanAt!)
        : 'Never';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DQ.radiusXl),
          border: Border.all(
            color: isPrimary ? color.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.06),
            width: isPrimary ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isPrimary ? 0.14 : 0.06),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                VehicleHeroStage(
                  vehicle: vehicle,
                  height: 220,
                  highlightColor: color,
                  compact: true,
                  interactive: false,
                  borderRadius: 0,
                  mood: mood,
                  weatherEffectsEnabled: weatherEffectsEnabled,
                  onAddPhoto: onPhotoTap,
                ),
                if (onPhotoTap != null)
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Material(
                      color: DQ.voidBlack.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: onPhotoTap,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.photo_camera_rounded, color: DQ.cyan, size: 20),
                        ),
                      ),
                    ),
                  ),
                if (isPrimary)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: DQ.voidBlack.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.45)),
                      ),
                      child: Text(
                        'PRIMARY',
                        style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: HealthRing(score: health.score, status: health.status, size: 68),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    DQ.graphite2.withValues(alpha: 0.92),
                    DQ.voidBlack,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vehicle.nickname != null && vehicle.nickname!.isNotEmpty)
                    Text(
                      vehicle.nickname!.toUpperCase(),
                      style: const TextStyle(
                        color: DQ.cyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                  Text(
                    vehicle.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DQ.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${vehicle.year} • ${vehicle.mileageKm ?? 0} km',
                    style: const TextStyle(color: DQ.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Chip(label: health.status.label, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Last scan $lastScan',
                          style: const TextStyle(color: DQ.textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
      ),
    );
  }
}
