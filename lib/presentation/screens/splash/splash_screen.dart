import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../widgets/launch/driviq_animated_logo.dart';

/// Premium launch splash — static approved logo, controlled motion, no layout jump.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.bootstrapReady,
    required this.onComplete,
  });

  final bool bootstrapReady;
  final VoidCallback onComplete;

  static const duration = Duration(milliseconds: 2100);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logo;
  late final Animation<double> _glow;
  late final Animation<double> _exit;

  bool _finished = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: SplashScreen.duration);

    _logo = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.42, curve: Curves.easeOutCubic));
    _glow = CurvedAnimation(parent: _ctrl, curve: const Interval(0.08, 0.55, curve: Curves.easeOutCubic));
    _exit = CurvedAnimation(parent: _ctrl, curve: const Interval(0.82, 1.0, curve: Curves.easeInCubic));

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finished = true;
        _tryComplete();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (_reduceMotion) {
      _finished = true;
      _tryComplete();
      return;
    }
    _ctrl.forward();
  }

  bool get _reduceMotion => PlatformDispatcher.instance.accessibilityFeatures.disableAnimations;

  void _tryComplete() {
    if (_completed || !mounted) return;
    if (_finished && widget.bootstrapReady) {
      _completed = true;
      widget.onComplete();
    }
  }

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
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
    return Material(
      color: DQ.voidBlack,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.1,
            colors: [
              const Color(0xFF121A24),
              DQ.voidBlack,
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final exiting = _ctrl.value > 0.82;
            final opacity = _reduceMotion ? 1.0 : (exiting ? 1 - _exit.value : 1.0);

            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Center(
                child: DriviqAnimatedLogo(
                  progress: _reduceMotion ? 1 : _logo.value,
                  glow: _reduceMotion ? 0.6 : _glow.value,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
