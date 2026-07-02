import 'dart:async';
import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import '../../domain/entities/scan_session.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/enums/health_status.dart';
import '../../domain/enums/scan_source.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import 'interfaces/diagnosis_services.dart';

/// Phase 1 on-device diagnosis pipeline — replays persisted analysis stages
/// while the real microphone/FFT pipeline is built in Phase 4.
class LocalDiagnosisService implements AiDiagnosisService {
  LocalDiagnosisService(this._diagnosisRepository);

  final DiagnosisRepository _diagnosisRepository;
  static const _uuid = Uuid();

  static const stages = [
    'Analyzing engine harmonics…',
    'Comparing vibration signatures…',
    'Detecting abnormal frequencies…',
    'Estimating mechanical confidence…',
    'Building repair recommendations…',
  ];

  @override
  Stream<DiagnosisStage> analyze({
    required Vehicle vehicle,
    required Stream<AudioFrame> audioFrames,
  }) async* {
    for (var i = 0; i < stages.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      yield DiagnosisStage(
        label: stages[i],
        progress: (i + 1) / stages.length,
      );
    }
  }

  @override
  Future<ScanSession> buildSession({
    required Vehicle vehicle,
    required List<DiagnosisStage> stages,
  }) async {
    final baseline = await _diagnosisRepository.getLatestForVehicle(vehicle.id);
    final faults = baseline?.faults ?? const [];
    final score = baseline?.healthScore ?? 94;

    return ScanSession(
      id: _uuid.v4(),
      vehicleId: vehicle.id,
      startedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      completedAt: DateTime.now(),
      healthScore: score,
      healthStatus: _statusForScore(score),
      summary: baseline?.summary ?? 'Baseline analysis complete.',
      faults: faults,
      sources: const [ScanSource.microphone, ScanSource.offlineAi, ScanSource.combined],
    );
  }

  HealthStatus _statusForScore(int score) {
    if (score >= 95) return HealthStatus.excellent;
    if (score >= 85) return HealthStatus.good;
    if (score >= 70) return HealthStatus.attention;
    return HealthStatus.critical;
  }
}

/// Simulated audio frames for Phase 1 scan animation.
class SimulatedAudioAnalysisService implements AudioAnalysisService {
  SimulatedAudioAnalysisService();

  final _controller = StreamController<AudioFrame>.broadcast();
  Timer? _timer;
  bool _listening = false;
  final _random = math.Random(42);

  @override
  Stream<AudioFrame> get frames => _controller.stream;

  @override
  bool get isListening => _listening;

  @override
  Future<void> start() async {
    if (_listening) return;
    _listening = true;
    _timer = Timer.periodic(const Duration(milliseconds: 48), (_) {
      final amps = List.generate(32, (i) => _random.nextDouble() * (i.isEven ? 0.9 : 0.5));
      final freqs = List.generate(32, (i) => i * 120.0 + _random.nextDouble() * 40);
      _controller.add(AudioFrame(
        amplitudes: amps,
        frequencies: freqs,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Future<void> stop() async {
    _listening = false;
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
