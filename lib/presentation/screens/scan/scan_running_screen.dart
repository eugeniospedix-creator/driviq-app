import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/usecase_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/errors/app_exception.dart';
import '../../../services/interfaces/diagnosis_services.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/scan/scan_visuals.dart';
import '../../widgets/scan/scan_waveform_panel.dart';
import '../../widgets/vehicle/interactive_vehicle_viewer.dart';

class ScanRunningScreen extends ConsumerStatefulWidget {
  const ScanRunningScreen({super.key});

  @override
  ConsumerState<ScanRunningScreen> createState() => _ScanRunningScreenState();
}

class _ScanRunningScreenState extends ConsumerState<ScanRunningScreen> {
  String _stageLabel = 'Initializing sensors…';
  double _progress = 0;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runScan());
  }

  Future<void> _runScan() async {
    final vehicle = await ref.read(primaryVehicleProvider.future);
    if (!mounted) return;
    if (vehicle == null) {
      context.go(AppRoutes.scan);
      return;
    }

    final useCase = ref.read(runScanUseCaseProvider);
    final stages = <DiagnosisStage>[];

    try {
      await for (final stage in useCase.analyze(vehicle)) {
        if (!mounted) return;
        setState(() {
          _stageLabel = stage.label;
          _progress = stage.progress;
        });
        stages.add(stage);
      }

      await useCase.complete(vehicle, stages);
      ref.invalidate(latestScanProvider(vehicle.id));
      ref.invalidate(vehicleHealthProvider(vehicle.id));
      ref.invalidate(garageOverviewProvider);

    if (!mounted) return;
    context.pushReplacement(AppRoutes.diagnosisResult);
      return;
    } on AppException catch (error) {
      if (!mounted) return;
      _showFailure(error.message);
    } catch (_) {
      if (!mounted) return;
      _showFailure('Scan could not be completed. Please try again.');
    } finally {
      await useCase.cancel();
      if (mounted) setState(() => _running = false);
    }
  }

  void _showFailure(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DQ.graphite3,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go(AppRoutes.scan);
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(primaryVehicleProvider);

    return Scaffold(
      backgroundColor: DQ.voidBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'DRIVIQ CORE',
                style: const TextStyle(
                  color: DQ.textMuted,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: vehicleAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (vehicle) => vehicle == null
                      ? const SizedBox()
                      : RepaintBoundary(
                          child: InteractiveVehicleViewer(
                            vehicle: vehicle,
                            scanning: _running,
                            showGlow: true,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              if (_running) const ScanWaveformPanel(),
              const SizedBox(height: 24),
              Text(
                _stageLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DQ.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Park safely. Do not interact while driving.',
                style: TextStyle(color: DQ.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 28),
              ScanProgressBar(progress: _progress),
              const SizedBox(height: 14),
              Text(
                '${(_progress * 100).round()}%',
                style: const TextStyle(
                  color: DQ.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
