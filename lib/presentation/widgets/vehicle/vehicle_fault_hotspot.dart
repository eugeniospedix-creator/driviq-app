import 'package:flutter/material.dart';

import '../../../core/visuals/fault_severity_colors.dart';
import '../../../domain/enums/fault_severity.dart';

class VehicleFaultHotspot extends StatelessWidget {
  const VehicleFaultHotspot({
    super.key,
    required this.severity,
    required this.selected,
    required this.interactive,
    this.onTap,
  });

  final FaultSeverity severity;
  final bool selected;
  final bool interactive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = FaultSeverityColors.accent(severity);

    return GestureDetector(
      onTap: interactive ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: selected ? 38 : 28,
        height: selected ? 38 : 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: selected ? 0.95 : 0.82),
          border: Border.all(color: Colors.white.withValues(alpha: 0.92), width: selected ? 2.5 : 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: selected ? 28 : 14),
          ],
        ),
      ),
    );
  }
}
