import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../widgets/launch/launch_splash_painter.dart';

/// Cinematic launch sequence — glowing car-light draws the Driviq logo, then fades to app.
class LaunchSplashScreen extends StatefulWidget {
  const LaunchSplashScreen({
    super.key,
    required this.bootstrapReady,
    required this.onComplete,
  });

  final bool bootstrapReady;
  final VoidCallback onComplete;

  static const duration = Duration(milliseconds: 2200);

  @override
  State<LaunchSplashScreen> createState() => _LaunchSplashScreenState();
}

class _LaunchSplashScreenState extends State<LaunchSplashScreen> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _draw;
  late final Animation<double> _pulse;
  late final Animation<double> _settle;
  late final Animation<double> _leader;
  late final Animation<double> _bg;

  bool _animationFinished = false;
  bool _completed = false;
  bool _exiting = false;
  late final AnimationController _exit;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: LaunchSplashScreen.duration);
    _exit = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _exitFade = CurvedAnimation(parent: _exit, curve: Curves.easeOutCubic);

    _draw = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.06, 0.68, curve: Curves.easeInOutCubic),
    );

    _pulse = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.68, 0.84, curve: Curves.easeOutCubic),
    );

    _settle = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.82, 1.0, curve: Curves.easeOutCubic),
    );

    _leader = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 32),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _bg = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationFinished = true;
        _tryComplete();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (_reduceMotion) {
      _animationFinished = true;
      _tryComplete();
      return;
    }
    _ctrl.forward();
  }

  bool get _reduceMotion {
    final dispatcher = PlatformDispatcher.instance;
    return dispatcher.accessibilityFeatures.disableAnimations;
  }

  Future<void> _tryComplete() async {
    if (_completed || !mounted) return;
    if (_animationFinished && widget.bootstrapReady) {
      _completed = true;
      if (!_reduceMotion) {
        setState(() => _exiting = true);
        await _exit.forward();
      }
      if (mounted) widget.onComplete();
    }
  }

  @override
  void didUpdateWidget(covariant LaunchSplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bootstrapReady && !oldWidget.bootstrapReady) {
      _tryComplete();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DQ.voidBlack,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final draw = _reduceMotion ? 1.0 : _draw.value;
            final pulse = _reduceMotion ? 0.0 : _pulse.value;
            final settle = _reduceMotion ? 1.0 : _settle.value;

            return FadeTransition(
              opacity: _exiting
                  ? Tween<double>(begin: 1, end: 0).animate(_exitFade)
                  : const AlwaysStoppedAnimation(1),
              child: CustomPaint(
                painter: LaunchSplashPainter(
                  drawProgress: draw,
                  pulse: pulse,
                  settle: settle,
                  leaderOpacity: _reduceMotion ? 0 : _leader.value,
                  backgroundPulse: _bg.value,
                ),
                child: const SizedBox.expand(),
              ),
            );
          },
        ),
      ),
    );
  }
}
