import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';

class ScanProgressBar extends StatelessWidget {
  const ScanProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08))),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0, 1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [DQ.cyanDim, DQ.cyan, DQ.emerald],
                  ),
                  boxShadow: [
                    BoxShadow(color: DQ.cyan.withValues(alpha: 0.5), blurRadius: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AudioWaveform extends StatelessWidget {
  const AudioWaveform({super.key, required this.amplitudes});

  final List<double> amplitudes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(amplitudes.length.clamp(0, 24), (i) {
          final amp = amplitudes[i];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                height: 8 + amp * 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      DQ.cyanDim.withValues(alpha: 0.5),
                      DQ.cyan,
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
