import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/enums/vehicle_view_mode.dart';
import '../../providers/repository_providers.dart';

class VehicleViewer extends ConsumerStatefulWidget {
  const VehicleViewer({
    super.key,
    required this.vehicle,
    this.viewMode = VehicleViewMode.exterior,
    this.scanning = false,
    this.interactive = false,
    this.faults = const [],
    this.highlightedFault,
    this.onFaultSelected,
    this.height,
  });

  final Vehicle vehicle;
  final VehicleViewMode viewMode;
  final bool scanning;
  final bool interactive;
  final List<ComponentFault> faults;
  final ComponentFault? highlightedFault;
  final ValueChanged<ComponentFault>? onFaultSelected;
  final double? height;

  @override
  ConsumerState<VehicleViewer> createState() => _VehicleViewerState();
}

class _VehicleViewerState extends ConsumerState<VehicleViewer> with SingleTickerProviderStateMixin {
  late final AnimationController _phase;

  @override
  void initState() {
    super.initState();
    _phase = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    if (widget.scanning) _phase.repeat();
  }

  @override
  void didUpdateWidget(covariant VehicleViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scanning && !_phase.isAnimating) {
      _phase.repeat();
    } else if (!widget.scanning && _phase.isAnimating) {
      _phase.stop();
      _phase.value = 0;
    }
  }

  @override
  void dispose() {
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final renderer = ref.read(vehicleRendererProvider);
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _phase,
        builder: (context, _) {
          return renderer.build(
            vehicle: widget.vehicle,
            viewMode: widget.viewMode,
            scanning: widget.scanning,
            interactive: widget.interactive,
            highlightedFault: widget.highlightedFault,
            onFaultSelected: widget.onFaultSelected,
            faults: widget.faults,
            animationPhase: _phase.value,
          );
        },
      ),
    );
  }
}
