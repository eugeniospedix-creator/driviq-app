import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/vehicle_health.dart';
import '../health/health_ring.dart';
import '../shell/dq_page.dart';
import '../vehicle/vehicle_viewer.dart';

class VehicleGarageCard extends StatelessWidget {
  const VehicleGarageCard({
    super.key,
    required this.vehicle,
    required this.health,
    required this.onTap,
    this.compact = false,
  });

  final Vehicle vehicle;
  final VehicleHealth health;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = DQ.healthColor(health.score);
    final lastScan = health.lastScanAt != null
        ? DateFormat.MMMd().format(health.lastScanAt!)
        : 'Never';

    return GestureDetector(
      onTap: onTap,
      child: DarkPanel(
        glowColor: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (vehicle.nickname != null)
                        Text(
                          vehicle.nickname!.toUpperCase(),
                          style: const TextStyle(
                            color: DQ.cyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                          ),
                        ),
                      Text(
                        vehicle.displayName,
                        style: const TextStyle(
                          color: DQ.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle.year} • ${vehicle.mileageKm ?? 0} km',
                        style: const TextStyle(color: DQ.textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                HealthRing(score: health.score, status: health.status, size: compact ? 72 : 84),
              ],
            ),
            SizedBox(height: compact ? 14 : 18),
            VehicleViewer(
              vehicle: vehicle,
              height: compact ? 140 : 200,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Chip(label: health.status.label, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Last scan $lastScan',
                    style: const TextStyle(color: DQ.textMuted, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
        color: color.withValues(alpha: 0.15),
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
