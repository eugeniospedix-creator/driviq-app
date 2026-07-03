import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';

/// Launch splash — static approved Driviq logo, brief fade, then hand off to app.
class LaunchSplashScreen extends StatefulWidget {
  const LaunchSplashScreen({
    super.key,
    required this.bootstrapReady,
    required this.onComplete,
  });

  final bool bootstrapReady;
  final VoidCallback onComplete;

  static const duration = Duration(milliseconds: 1400);

  @override
  State<LaunchSplashScreen> createState() => _LaunchSplashScreenState();
}

class _LaunchSplashScreenState extends State<LaunchSplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _exitFade;

  bool _holdFinished = false;
  bool _completed = false;

  static const _logoAsset = 'assets/brand/driviq_app_icon.png';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: LaunchSplashScreen.duration);

    _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );

    _exitFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.72, 1.0, curve: Curves.easeInCubic),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _holdFinished = true;
        _tryComplete();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (_reduceMotion) {
      _holdFinished = true;
      _tryComplete();
      return;
    }
    _ctrl.forward();
  }

  bool get _reduceMotion => PlatformDispatcher.instance.accessibilityFeatures.disableAnimations;

  Future<void> _tryComplete() async {
    if (_completed || !mounted) return;
    if (_holdFinished && widget.bootstrapReady) {
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
    final size = MediaQuery.sizeOf(context);
    final logoSide = size.shortestSide * 0.34;

    return Material(
      color: DQ.voidBlack,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final exiting = _ctrl.value > 0.72;
          final opacity = exiting ? 1 - _exitFade.value : _logoFade.value;

          return Opacity(
            opacity: _reduceMotion ? 1 : opacity.clamp(0.0, 1.0),
            child: Center(
              child: SizedBox(
                width: logoSide,
                height: logoSide,
                child: Image.asset(
                  _logoAsset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
