import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import 'driviq_animated_logo.dart';

/// Cinematic launch splash — approved logo, calm motion, studio glow.
class PremiumSplashScene extends StatefulWidget {
  const PremiumSplashScene({
    super.key,
    required this.bootstrapReady,
    required this.onComplete,
  });

  final bool bootstrapReady;
  final VoidCallback onComplete;

  static const duration = Duration(milliseconds: 2200);

  @override
  State<PremiumSplashScene> createState() => _PremiumSplashSceneState();
}

class _PremiumSplashSceneState extends State<PremiumSplashScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _glow;
  late final Animation<double> _exit;
  bool _animationDone = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: PremiumSplashScene.duration);
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.38, curve: Curves.easeOutCubic),
    );
    _glow = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.06, 0.72, curve: Curves.easeOutCubic),
    );
    _exit = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.80, 1.0, curve: Curves.easeInCubic),
    );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationDone = true;
        _tryComplete();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  bool get _reduceMotion =>
      PlatformDispatcher.instance.accessibilityFeatures.disableAnimations;

  void _start() {
    if (_reduceMotion) {
      _animationDone = true;
      _tryComplete();
    } else {
      _ctrl.forward();
    }
  }

  void _tryComplete() {
    if (_completed || !mounted) return;
    if (_animationDone && widget.bootstrapReady) {
      _completed = true;
      widget.onComplete();
    }
  }

  @override
  void didUpdateWidget(covariant PremiumSplashScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bootstrapReady && !oldWidget.bootstrapReady) _tryComplete();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final logoSize = shortest.clamp(300.0, 500.0) * 0.32;

    return Material(
      color: DQ.voidBlack,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final exitOpacity = _ctrl.value > 0.80 ? 1 - _exit.value : 1.0;
          final master = _reduceMotion ? 1.0 : (_fade.value * exitOpacity).clamp(0.0, 1.0);
          final glow = _reduceMotion ? 0.75 : _glow.value;

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.18),
                radius: 1.0,
                colors: [
                  const Color(0xFF162636).withValues(alpha: 0.95),
                  const Color(0xFF0A1018),
                  DQ.voidBlack,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            child: Center(
              child: Opacity(
                opacity: master,
                child: DriviqAnimatedLogo(
                  progress: master,
                  glow: glow,
                  size: logoSize,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
