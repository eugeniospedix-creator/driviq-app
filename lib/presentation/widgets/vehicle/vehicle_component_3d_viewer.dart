import 'dart:io';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/catalog/vehicle_component_hotspot_layout.dart';
import 'user_vehicle_studio_image.dart';

/// Component-level visual — real GLB when available, honest 2.5D photo otherwise.
class VehicleComponent3DViewer extends StatelessWidget {
  const VehicleComponent3DViewer({
    super.key,
    required this.vehicle,
    required this.componentId,
    this.fault,
    this.glbPath,
    this.height = 220,
  });

  final Vehicle vehicle;
  final String componentId;
  final ComponentFault? fault;
  final String? glbPath;
  final double height;

  @override
  Widget build(BuildContext context) {
    final name = fault?.name ?? VehicleComponentHotspotLayout.displayNames[componentId] ?? 'Component';
    final hasGlb = glbPath != null && glbPath!.isNotEmpty && File(glbPath!).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: DQ.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasGlb ? 'Interactive 3D component view' : 'Studio photo view — full 3D component mesh pending',
          style: const TextStyle(color: DQ.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DQ.radiusLg),
            child: hasGlb
                ? ModelViewer(
                    src: 'file://${File(glbPath!).absolute.path}',
                    alt: name,
                    autoRotate: true,
                    cameraControls: true,
                    disableZoom: false,
                    backgroundColor: DQ.voidBlack,
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C2632), DQ.voidBlack],
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: UserVehicleStudioImage(
                      vehicle: vehicle,
                      compact: true,
                      showReflection: true,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
