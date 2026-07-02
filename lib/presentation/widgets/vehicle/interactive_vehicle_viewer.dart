import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/vehicle_3d_view_state.dart';
import '../../../domain/enums/vehicle_view_mode.dart';
import '../../providers/repository_providers.dart';
import 'view_mode_selector.dart';

class InteractiveVehicleViewer extends ConsumerStatefulWidget {
  const InteractiveVehicleViewer({
    super.key,
    required this.vehicle,
    this.viewMode = VehicleViewMode.exterior,
    this.scanning = false,
    this.interactive = true,
    this.showViewModes = false,
    this.showGlow = false,
    this.faults = const [],
    this.highlightedFault,
    this.onFaultSelected,
    this.height,
  });

  final Vehicle vehicle;
  final VehicleViewMode viewMode;
  final bool scanning;
  final bool interactive;
  final bool showViewModes;
  final bool showGlow;
  final List<ComponentFault> faults;
  final ComponentFault? highlightedFault;
  final ValueChanged<ComponentFault>? onFaultSelected;
  final double? height;

  @override
  ConsumerState<InteractiveVehicleViewer> createState() => _InteractiveVehicleViewerState();
}

class _InteractiveVehicleViewerState extends ConsumerState<InteractiveVehicleViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _phase;
  Vehicle3DViewState _viewState = const Vehicle3DViewState();
  late VehicleViewMode _viewMode;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.viewMode;
    _phase = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    if (widget.scanning) _phase.repeat();
  }

  @override
  void didUpdateWidget(covariant InteractiveVehicleViewer oldWidget) {
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
    final metadataAsync = ref.watch(vehicleMetadataProvider(widget.vehicle));
    final renderer = ref.read(vehicleRendererProvider);

    return metadataAsync.when(
      loading: () => SizedBox(
        height: widget.height,
        child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: DQ.cyan))),
      ),
      error: (_, _) => SizedBox(height: widget.height),
      data: (metadata) {
        final viewer = GestureDetector(
          onPanUpdate: widget.interactive
              ? (d) => setState(() {
                    _viewState = _viewState.copyWith(
                      yaw: _viewState.yaw + d.delta.dx * 0.004,
                      pitch: (_viewState.pitch + d.delta.dy * 0.003).clamp(-0.35, 0.35),
                    );
                  })
              : null,
          onScaleUpdate: widget.interactive
              ? (d) => setState(() {
                    _viewState = _viewState.copyWith(zoom: _viewState.zoom * d.scale);
                  })
              : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.showGlow)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, 0.2),
                        radius: 0.85,
                        colors: [
                          DQ.cyan.withValues(alpha: widget.scanning ? 0.18 : 0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              AnimatedBuilder(
                animation: _phase,
                builder: (context, _) {
                  return renderer.build(
                    vehicle: widget.vehicle,
                    viewMode: _viewMode,
                    viewState: _viewState,
                    metadata: metadata,
                    scanning: widget.scanning,
                    interactive: widget.interactive,
                    highlightedFault: widget.highlightedFault,
                    onFaultSelected: widget.onFaultSelected,
                    faults: widget.faults,
                    animationPhase: _phase.value,
                  );
                },
              ),
            ],
          ),
        );

        final modeBar = widget.showViewModes
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ViewModeSelector(
                  selected: _viewMode,
                  onSelected: (mode) => setState(() => _viewMode = mode),
                ),
              )
            : null;

        if (widget.height != null) {
          return SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Column(
              children: [
                if (modeBar != null) modeBar,
                Expanded(child: viewer),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (modeBar != null) modeBar,
            Expanded(child: viewer),
          ],
        );
      },
    );
  }
}
