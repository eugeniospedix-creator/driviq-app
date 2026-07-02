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
                  gradient: const LinearGradient(
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

/// GPU-friendly waveform — isolated repaints via [RepaintBoundary] + [CustomPainter].
class AudioWaveform extends StatelessWidget {
  const AudioWaveform({super.key, required this.amplitudes});

  final List<double> amplitudes;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(double.infinity, 64),
        painter: _WaveformPainter(amplitudes: amplitudes),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.amplitudes});

  final List<double> amplitudes;

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = amplitudes.length.clamp(1, 24);
    final barWidth = size.width / barCount;

    for (var i = 0; i < barCount; i++) {
      final amp = amplitudes[i].clamp(0.0, 1.0);
      final height = 8 + amp * 52;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * barWidth + 1.5,
          size.height - height,
          barWidth - 3,
          height,
        ),
        const Radius.circular(4),
      );
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            DQ.cyanDim.withValues(alpha: 0.5),
            DQ.cyan,
          ],
        ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    if (oldDelegate.amplitudes.length != amplitudes.length) return true;
    for (var i = 0; i < amplitudes.length && i < 24; i++) {
      if ((oldDelegate.amplitudes[i] - amplitudes[i]).abs() > 0.02) return true;
    }
    return false;
  }
}
