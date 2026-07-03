import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/catalog/vehicle_component_hotspot_layout.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle.dart';
import 'vehicle_component_3d_viewer.dart';

class ComponentDetailSheet extends StatelessWidget {
  const ComponentDetailSheet({
    super.key,
    required this.vehicle,
    required this.componentId,
    this.fault,
    this.glbPath,
  });

  final Vehicle vehicle;
  final String componentId;
  final ComponentFault? fault;
  final String? glbPath;

  static Future<void> show(
    BuildContext context, {
    required Vehicle vehicle,
    required String componentId,
    ComponentFault? fault,
    String? glbPath,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DQ.graphite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DQ.radiusXl)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(22, 18, 22, MediaQuery.paddingOf(context).bottom + 24),
        child: ComponentDetailSheet(
          vehicle: vehicle,
          componentId: componentId,
          fault: fault,
          glbPath: glbPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = fault?.name ?? VehicleComponentHotspotLayout.displayNames[componentId] ?? 'Component';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 18),
        VehicleComponent3DViewer(
          vehicle: vehicle,
          componentId: componentId,
          fault: fault,
          glbPath: glbPath,
        ),
        const SizedBox(height: 16),
        if (fault != null) ...[
          Text(
            fault!.finding,
            style: const TextStyle(color: DQ.textSecondary, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 10),
          Text(
            fault!.recommendation,
            style: TextStyle(color: DQ.cyan.withValues(alpha: 0.92), fontSize: 13, height: 1.4),
          ),
        ] else
          const Text(
            'No issues flagged for this component in the latest scan.',
            style: TextStyle(color: DQ.textMuted, fontSize: 13, height: 1.4),
          ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(color: DQ.textMuted, fontSize: 11, letterSpacing: 1.2),
        ),
      ],
    );
  }
}
