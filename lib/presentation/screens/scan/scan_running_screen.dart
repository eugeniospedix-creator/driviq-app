import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../services/interfaces/diagnosis_services.dart';
import '../../providers/repository_providers.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/scan/scan_visuals.dart';
import '../../widgets/vehicle/vehicle_viewer.dart';

class ScanRunningScreen extends ConsumerStatefulWidget {
  const ScanRunningScreen({super.key});

  @override
  ConsumerState<ScanRunningScreen> createState() => _ScanRunningScreenState();
}

class _ScanRunningScreenState extends ConsumerState<ScanRunningScreen> {
  String _stageLabel = 'Initializing sensors…';
  double _progress = 0;
  List<double> _amps = List.filled(24, 0.1);
  StreamSubscription<AudioFrame>? _audioSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runScan());
  }

  Future<void> _runScan() async {
    final vehicle = await ref.read(primaryVehicleProvider.future);
    if (!mounted || vehicle == null) {
      if (mounted) context.go(AppRoutes.scan);
      return;
    }

    final audio = ref.read(audioAnalysisServiceProvider);
    final ai = ref.read(aiDiagnosisServiceProvider);

    await audio.start();
    _audioSub = audio.frames.listen((frame) {
      if (!mounted) return;
      setState(() => _amps = frame.amplitudes);
    });

    final stages = <DiagnosisStage>[];
    await for (final stage in ai.analyze(vehicle: vehicle, audioFrames: audio.frames)) {
      if (!mounted) return;
      setState(() {
        _stageLabel = stage.label;
        _progress = stage.progress;
      });
      stages.add(stage);
    }
    await audio.stop();

    final session = await ai.buildSession(vehicle: vehicle, stages: stages);
    await ref.read(diagnosisRepositoryProvider).save(session);
    ref.invalidate(latestScanProvider(vehicle.id));
    ref.invalidate(vehicleHealthProvider(vehicle.id));
    ref.read(activeScanSessionProvider.notifier).state = session;

    if (!mounted) return;
    context.go(AppRoutes.report);
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    super.dispose();
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
                'DRIVIQ CORE'.toUpperCase(),
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
                  error: (_, __) => const SizedBox(),
                  data: (vehicle) => vehicle == null
                      ? const SizedBox()
                      : VehicleViewer(
                          vehicle: vehicle,
                          scanning: true,
                          height: double.infinity,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              AudioWaveform(amplitudes: _amps),
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
