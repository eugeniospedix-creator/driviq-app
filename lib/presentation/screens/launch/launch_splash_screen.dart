import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../widgets/launch/driviq_splash_animation.dart';
import '../../widgets/launch/driviq_splash_painter.dart';

class LaunchSplashScreen extends StatefulWidget {
  const LaunchSplashScreen({
    super.key,
    required this.bootstrapReady,
    required this.onComplete,
  });

  final bool bootstrapReady;
  final VoidCallback onComplete;

  static const duration = Duration(milliseconds: DriviqSplashAnimation.totalMs);

  @override
  State<LaunchSplashScreen> createState() => _LaunchSplashScreenState();
}

class _LaunchSplashScreenState extends State<LaunchSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _animationDone = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: LaunchSplashScreen.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationDone = true;
          _tryComplete();
        }
      });
    SchedulerBinding.instance.addPostFrameCallback((_) => _start());
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
  void didUpdateWidget(covariant LaunchSplashScreen oldWidget) {
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
      color: DriviqSplashAnimation.background,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _reduceMotion ? 1.0 : _ctrl.value;
            return CustomPaint(
              painter: DriviqSplashPainter(t: t),
              size: MediaQuery.sizeOf(context),
            );
          },
        ),
      ),
    );
  }
}
