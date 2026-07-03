import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';

class CinematicAmbient extends StatefulWidget {
  const CinematicAmbient({
    super.key,
    required this.healthColor,
    this.parallax = 0,
  });

  final Color healthColor;
  final double parallax;

  @override
  State<CinematicAmbient> createState() => _CinematicAmbientState();
}

class _CinematicAmbientState extends State<CinematicAmbient> with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _drift,
      builder: (context, _) {
        final t = _drift.value * 2 * math.pi;
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -140 + widget.parallax * 0.12,
              left: -60 + math.sin(t) * 18,
              child: _Orb(color: widget.healthColor.withValues(alpha: 0.22), size: 320),
            ),
            Positioned(
              top: 80 + widget.parallax * 0.08,
              right: -100 + math.cos(t) * 14,
              child: _Orb(color: DQ.cyan.withValues(alpha: 0.14), size: 240),
            ),
            Positioned(
              bottom: 120 - widget.parallax * 0.05,
              left: 40,
              child: _Orb(color: widget.healthColor.withValues(alpha: 0.08), size: 180),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    DQ.voidBlack.withValues(alpha: 0.05),
                    DQ.voidBlack.withValues(alpha: 0.55),
                    DQ.voidBlack,
                  ],
                  stops: const [0.0, 0.62, 1.0],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
