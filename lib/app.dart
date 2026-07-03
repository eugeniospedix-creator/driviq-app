import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/dq_theme.dart';
import 'presentation/providers/bootstrap_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

class DriviqApp extends ConsumerStatefulWidget {
  const DriviqApp({super.key});

  @override
  ConsumerState<DriviqApp> createState() => _DriviqAppState();
}

class _DriviqAppState extends ConsumerState<DriviqApp> {
  bool _showLaunch = true;

  @override
  Widget build(BuildContext context) {
    final bootstrap = ref.watch(bootstrapProvider);
    final bootstrapReady = bootstrap.hasValue;

    if (_showLaunch) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DriviqTheme.dark,
        home: SplashScreen(
          bootstrapReady: bootstrapReady,
          onComplete: () {
            if (mounted) setState(() => _showLaunch = false);
          },
        ),
      );
    }

    return bootstrap.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DriviqTheme.dark,
        home: const Scaffold(
          backgroundColor: Color(0xFF05080C),
          body: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF22D3EE)),
            ),
          ),
        ),
      ),
      error: (e, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DriviqTheme.dark,
        home: Scaffold(
          backgroundColor: const Color(0xFF05080C),
          body: Center(child: Text('Failed to start Driviq: $e')),
        ),
      ),
      data: (_) => MaterialApp.router(
        title: 'Driviq',
        debugShowCheckedModeBanner: false,
        theme: DriviqTheme.dark,
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}
