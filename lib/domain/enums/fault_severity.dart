enum FaultSeverity {
  normal,
  monitor,
  attention,
  critical;

  String get label => switch (this) {
        FaultSeverity.normal => 'Normal',
        FaultSeverity.monitor => 'Monitor',
        FaultSeverity.attention => 'Attention',
        FaultSeverity.critical => 'Critical',
      };
}
