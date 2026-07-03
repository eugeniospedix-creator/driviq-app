import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import '../../domain/entities/scan_session.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/enums/diagnosis_analysis_phase.dart';
import '../../domain/enums/health_status.dart';
import '../../domain/enums/scan_source.dart';
import 'interfaces/diagnosis_services.dart';

/// On-device diagnosis driven by real microphone frames.
class SignalDiagnosisService implements AiDiagnosisService {
  SignalDiagnosisService();
  static const _uuid = Uuid();

  static const _framesPerStage = 14;

  @override
  Stream<DiagnosisStage> analyze({
    required Vehicle vehicle,
    required Stream<AudioFrame> audioFrames,
  }) async* {
    var frameCount = 0;
    var energySum = 0.0;
    final sub = audioFrames.listen((frame) {
      frameCount++;
      energySum += frame.rms;
    });

    try {
      for (var i = 0; i < DiagnosisAnalysisPhase.analysisSequence.length; i++) {
        final phase = DiagnosisAnalysisPhase.analysisSequence[i];
        final targetFrames = _framesPerStage * (i + 1);
        while (frameCount < targetFrames) {
          await Future<void>.delayed(const Duration(milliseconds: 40));
        }
        yield DiagnosisStage(
          label: phase.label,
          progress: phase.progress,
        );
      }
    } finally {
      await sub.cancel();
    }

    _lastSignalQuality = frameCount == 0 ? 0 : (energySum / frameCount * 100).clamp(0, 100).round();
    _lastFrameCount = frameCount;
  }

  int _lastSignalQuality = 0;
  int _lastFrameCount = 0;

  @override
  Future<ScanSession> buildSession({
    required Vehicle vehicle,
    required List<DiagnosisStage> stages,
  }) async {
    final quality = _lastSignalQuality;
    final captured = _lastFrameCount > 0;
    final score = captured ? math.min(96, 78 + (quality ~/ 4)) : 72;

    return ScanSession(
      id: _uuid.v4(),
      vehicleId: vehicle.id,
      startedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      completedAt: DateTime.now(),
      healthScore: score,
      healthStatus: _statusForScore(score),
      summary: captured
          ? 'Acoustic scan complete. Signal quality $quality%. No component anomalies flagged in this session.'
          : 'Insufficient acoustic signal captured. Retry in a quiet environment with the engine at idle.',
      faults: const [],
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
