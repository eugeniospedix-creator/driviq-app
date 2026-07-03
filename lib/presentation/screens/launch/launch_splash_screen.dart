import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../widgets/launch/launch_splash_painter.dart';

/// Premium launch — static approved icon with subtle cyan glow and heartbeat trace.
class LaunchSplashScreen extends StatefulWidget {
  const LaunchSplashScreen({
    super.key,
    required this.bootstrapReady,
    required this.onComplete,
  });

  final bool bootstrapReady;
  final VoidCallback onComplete;

  static const duration = Duration(milliseconds: 1800);

  @override
  State<LaunchSplashScreen> createState() => _LaunchSplashScreenState();
}

class _LaunchSplashScreenState extends State<LaunchSplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoIn;
  late final Animation<double> _glow;
  late final Animation<double> _line;
  late final Animation<double> _pulse;
  late final Animation<double> _exitFade;

  bool _holdFinished = false;
  bool _completed = false;

  static const _logoAsset = 'assets/brand/driviq_app_icon.png';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: LaunchSplashScreen.duration);

    _logoIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.38, curve: Curves.easeOutCubic),
    );

    _glow = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.05, 0.55, curve: Curves.easeOutCubic),
    );

    _line = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.28, 0.72, curve: Curves.easeInOutCubic),
    );

    _pulse = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.72, 0.88, curve: Curves.easeOutCubic),
    );

    _exitFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.88, 1.0, curve: Curves.easeInCubic),
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
    final logoSide = MediaQuery.sizeOf(context).shortestSide * 0.34;

    return Material(
      color: DQ.voidBlack,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final exiting = _ctrl.value > 0.88;
          final screenOpacity = _reduceMotion ? 1.0 : (exiting ? 1 - _exitFade.value : 1.0);
          final logoOpacity = _reduceMotion ? 1.0 : _logoIn.value;
          final logoScale = _reduceMotion ? 1.0 : 0.94 + _logoIn.value * 0.06;

          return Opacity(
            opacity: screenOpacity.clamp(0.0, 1.0),
            child: Center(
              child: SizedBox(
                width: logoSide,
                height: logoSide,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: logoScale,
                      child: Opacity(
                        opacity: logoOpacity.clamp(0.0, 1.0),
                        child: Image.asset(
                          _logoAsset,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                    if (!_reduceMotion)
                      CustomPaint(
                        painter: LaunchSplashOverlayPainter(
                          glow: _glow.value,
                          lineProgress: _line.value,
                          pulse: _pulse.value,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
