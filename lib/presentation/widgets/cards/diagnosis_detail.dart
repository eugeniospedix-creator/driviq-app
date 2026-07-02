import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/enums/fault_severity.dart';

class DiagnosisMetric extends StatelessWidget {
  const DiagnosisMetric({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DQ.graphite3,
          borderRadius: BorderRadius.circular(DQ.radiusMd),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(color: DQ.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class FaultDetailCard extends StatelessWidget {
  const FaultDetailCard({super.key, required this.fault});

  final ComponentFault fault;

  Color get _color => switch (fault.severity) {
        FaultSeverity.normal => DQ.emerald,
        FaultSeverity.monitor => DQ.cyan,
        FaultSeverity.attention => DQ.amber,
        FaultSeverity.critical => DQ.coral,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _color.withValues(alpha: 0.6), blurRadius: 14)],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              fault.zone.label.toUpperCase(),
              style: const TextStyle(color: DQ.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          fault.name,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 10),
        Text(fault.finding, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        Row(
          children: [
            DiagnosisMetric(label: 'Confidence', value: '${fault.confidencePercent}%', color: _color),
            const SizedBox(width: 12),
            DiagnosisMetric(label: 'Signal', value: '${fault.signalQualityPercent}%', color: DQ.cyan),
          ],
        ),
        if (fault.whatHappened != null) ...[
          const SizedBox(height: 22),
          _Section(title: 'What happened', body: fault.whatHappened!),
        ],
        if (fault.whyItMatters != null) ...[
          const SizedBox(height: 16),
          _Section(title: 'Why it matters', body: fault.whyItMatters!),
        ],
        const SizedBox(height: 16),
        _Section(title: 'Can I still drive?', body: fault.driveability.explanation),
        if (fault.estimatedRepairCostMin != null) ...[
          const SizedBox(height: 16),
          _Section(
            title: 'Estimated repair',
            body: '€${fault.estimatedRepairCostMin!.round()} – €${fault.estimatedRepairCostMax!.round()} • '
                '${fault.estimatedRepairHoursMin!.toStringAsFixed(1)}–${fault.estimatedRepairHoursMax!.toStringAsFixed(1)} hours',
          ),
        ],
        if (fault.consequencesIfIgnored != null) ...[
          const SizedBox(height: 16),
          _Section(title: 'If ignored', body: fault.consequencesIfIgnored!),
        ],
        const SizedBox(height: 20),
        _Section(title: 'Recommended next step', body: fault.recommendedNextStep),
        const SizedBox(height: 14),
        const Text(
          'Driviq provides preliminary insights only. Confirm with a qualified mechanic.',
          style: TextStyle(color: DQ.textMuted, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(body, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
