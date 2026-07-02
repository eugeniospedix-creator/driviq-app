import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/scan_session.dart';
import '../../../domain/enums/fault_severity.dart';
import '../../../domain/entities/vehicle_health.dart';

class LastScanCard extends StatelessWidget {
  const LastScanCard({
    super.key,
    required this.health,
    this.scan,
  });

  final VehicleHealth health;
  final ScanSession? scan;

  @override
  Widget build(BuildContext context) {
    final when = health.lastScanAt != null
        ? DateFormat.MMMd().add_jm().format(health.lastScanAt!)
        : 'No scan yet';
    final topFault = scan?.faults
        .where((f) => f.severity == FaultSeverity.attention || f.severity == FaultSeverity.critical)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(DQ.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LAST SCAN',
            style: TextStyle(color: DQ.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4),
          ),
          const SizedBox(height: 8),
          Text(when, style: const TextStyle(color: DQ.textPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
          if (topFault != null) ...[
            const SizedBox(height: 8),
            Text(
              topFault.name,
              style: TextStyle(color: DQ.healthColor(health.score), fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              health.summary,
              style: const TextStyle(color: DQ.textSecondary, fontSize: 13, height: 1.35),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
