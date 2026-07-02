import 'package:flutter/widgets.dart';

import '../../domain/entities/component_fault.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/enums/vehicle_view_mode.dart';

/// Abstraction for vehicle rendering — vector today, GLB/AR tomorrow.
abstract class VehicleRenderer {
  Widget build({
    required Vehicle vehicle,
    required VehicleViewMode viewMode,
    required bool scanning,
    required bool interactive,
    ComponentFault? highlightedFault,
    ValueChanged<ComponentFault>? onFaultSelected,
    List<ComponentFault> faults,
    double animationPhase,
  });
}
