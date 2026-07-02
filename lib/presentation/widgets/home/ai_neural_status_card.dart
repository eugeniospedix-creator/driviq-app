import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';

class AiNeuralStatusCard extends StatefulWidget {
  const AiNeuralStatusCard({super.key, this.pulsing = true});

  final bool pulsing;

  @override
  State<AiNeuralStatusCard> createState() => _AiNeuralStatusCardState();
}

class _AiNeuralStatusCardState extends State<AiNeuralStatusCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    if (widget.pulsing) _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = 0.12 + _pulse.value * 0.12;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DQ.radiusLg),
            border: Border.all(color: DQ.cyan.withValues(alpha: 0.25 + _pulse.value * 0.15)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DQ.cyan.withValues(alpha: glow),
                DQ.graphite3.withValues(alpha: 0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(color: DQ.cyan.withValues(alpha: glow), blurRadius: 28, offset: const Offset(0, 12)),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: DQ.cyanSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.psychology_rounded, color: DQ.cyan, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Neural Engine Active',
                  style: TextStyle(color: DQ.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'Learning your vehicle acoustic baseline from every scan.',
                  style: TextStyle(color: DQ.textSecondary, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
