import 'package:flutter/material.dart';

import '../../core/visuals/fault_severity_colors.dart';
import '../../domain/enums/fault_severity.dart';

export '../../core/visuals/fault_severity_colors.dart';

extension FaultSeverityVisuals on FaultSeverity {
  Color get accentColor => FaultSeverityColors.accent(this);
}
