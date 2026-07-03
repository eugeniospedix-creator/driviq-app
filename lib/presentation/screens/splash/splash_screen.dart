import 'package:flutter/material.dart';

import '../launch/launch_splash_screen.dart';

/// Entry splash used by [DriviqApp] — delegates to the hard-reset launch screen.
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    required this.bootstrapReady,
    required this.onComplete,
  });

  final bool bootstrapReady;
  final VoidCallback onComplete;

  static const duration = LaunchSplashScreen.duration;

  @override
  Widget build(BuildContext context) {
    return LaunchSplashScreen(
      bootstrapReady: bootstrapReady,
      onComplete: onComplete,
    );
  }
}
