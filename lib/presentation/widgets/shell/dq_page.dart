import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';

class DqPage extends StatelessWidget {
  const DqPage({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DQ.voidBlack, DQ.graphite, DQ.graphite2],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [DQ.cyan.withValues(alpha: 0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DQ.spaceLg),
    this.radius = DQ.radiusLg,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: DQ.glass,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: DQ.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class DarkPanel extends StatelessWidget {
  const DarkPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DQ.spaceLg),
    this.glowColor = DQ.cyan,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DQ.graphite2,
        borderRadius: BorderRadius.circular(DQ.radiusXl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.14),
            blurRadius: 48,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
