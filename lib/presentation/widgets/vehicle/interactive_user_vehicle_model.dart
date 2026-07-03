import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle_studio_model.dart';
import '../../../domain/enums/driviq_weather_mood.dart';
import 'user_vehicle_studio_image.dart';
import 'vehicle_fault_hotspot.dart';

/// Stable 2.5D user vehicle — limited zoom/pan only (no rotation until real 3D mesh).
class InteractiveUserVehicleModel extends StatefulWidget {
  const InteractiveUserVehicleModel({
    super.key,
    required this.model,
    this.accent = DQ.cyan,
    this.mood,
    this.showReflection = true,
    this.interactive = true,
    this.compact = false,
    this.weatherEffectsEnabled = false,
    this.faults = const [],
    this.highlightedFault,
    this.onFaultSelected,
    this.onAddPhoto,
  });

  final VehicleStudioModel model;
  final Color accent;
  final DriviqWeatherMood? mood;
  final bool showReflection;
  final bool interactive;
  final bool compact;
  final bool weatherEffectsEnabled;
  final List<ComponentFault> faults;
  final ComponentFault? highlightedFault;
  final ValueChanged<ComponentFault>? onFaultSelected;
  final VoidCallback? onAddPhoto;

  @override
  State<InteractiveUserVehicleModel> createState() => _InteractiveUserVehicleModelState();
}

class _InteractiveUserVehicleModelState extends State<InteractiveUserVehicleModel> {
  final TransformationController _transform = TransformationController();

  @override
  void initState() {
    super.initState();
    _transform.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant InteractiveUserVehicleModel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldVehicle = oldWidget.model.vehicle;
    final newVehicle = widget.model.vehicle;
    if (oldVehicle.id != newVehicle.id || oldVehicle.photoPath != newVehicle.photoPath) {
      _transform.value = Matrix4.identity();
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _transform.removeListener(_rebuild);
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studio = UserVehicleStudioImage(
      vehicle: widget.model.vehicle,
      accent: widget.accent,
      mood: widget.mood,
      showReflection: widget.showReflection,
      weatherEffectsEnabled: widget.weatherEffectsEnabled,
      onAddPhoto: widget.onAddPhoto,
      compact: widget.compact,
    );

    Widget body = studio;
    if (widget.faults.isNotEmpty) {
      body = Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        children: [
          studio,
          LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: widget.faults.map((fault) {
                  final selected = widget.highlightedFault?.id == fault.id;
                  final hotspotSize = selected ? 38.0 : 28.0;
                  return Positioned(
                    left: fault.anchor.x * size.width - hotspotSize / 2,
                    top: fault.anchor.y * size.height - hotspotSize / 2,
                    child: VehicleFaultHotspot(
                      severity: fault.severity,
                      selected: selected,
                      interactive: widget.interactive,
                      onTap: () => widget.onFaultSelected?.call(fault),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      );
    }

    body = ClipRect(child: Center(child: body));

    if (!widget.interactive || !widget.model.usePhotoStudio25D) {
      return body;
    }

    return ClipRect(
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1.0,
        maxScale: 1.35,
        panEnabled: true,
        scaleEnabled: true,
        boundaryMargin: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        child: body,
      ),
    );
  }
}
