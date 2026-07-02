import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/dq_theme.dart';
import 'presentation/providers/bootstrap_provider.dart';

class DriviqApp extends ConsumerWidget {
  const DriviqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(bootstrapProvider);
    final router = ref.watch(routerProvider);

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
        routerConfig: router,
      ),
    );
  }
}
