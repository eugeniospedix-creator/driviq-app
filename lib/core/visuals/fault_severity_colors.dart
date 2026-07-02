import 'package:flutter/material.dart';

import '../theme/dq_tokens.dart';
import '../../domain/enums/fault_severity.dart';

/// Shared severity → color mapping for all visual layers.
abstract final class FaultSeverityColors {
  static Color accent(FaultSeverity severity) => switch (severity) {
        FaultSeverity.normal => DQ.emerald,
        FaultSeverity.monitor => DQ.cyan,
        FaultSeverity.attention => DQ.amber,
        FaultSeverity.critical => DQ.coral,
      };
}
