import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';

/// Approved Driviq logo with premium fade + scale + controlled glow.
class DriviqAnimatedLogo extends StatelessWidget {
  const DriviqAnimatedLogo({
    super.key,
    required this.progress,
    required this.glow,
    this.size,
  });

  /// Master animation value 0–1.
  final double progress;
  final double glow;
  final double? size;

  static const assetPath = 'assets/brand/driviq_app_icon.png';

  @override
  Widget build(BuildContext context) {
    final side = size ?? MediaQuery.sizeOf(context).shortestSide * 0.34;
    final fade = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final scale = 0.93 + fade * 0.07;

    return SizedBox(
      width: side,
      height: side,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (glow > 0)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DQ.cyan.withValues(alpha: 0.18 * glow),
                    blurRadius: 42 * glow,
                    spreadRadius: 4 * glow,
                  ),
                ],
              ),
            ),
          Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: fade,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
