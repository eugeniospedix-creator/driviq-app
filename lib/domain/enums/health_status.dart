enum HealthStatus {
  excellent,
  good,
  attention,
  critical;

  String get label => switch (this) {
        HealthStatus.excellent => 'Excellent',
        HealthStatus.good => 'Good',
        HealthStatus.attention => 'Attention',
        HealthStatus.critical => 'Critical',
      };
}
