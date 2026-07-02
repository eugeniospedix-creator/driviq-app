import '../../domain/entities/component_fault.dart';
import '../../domain/entities/scan_session.dart';
import '../../domain/entities/vehicle.dart';

/// Streams real-time audio analysis frames during a scan.
abstract class AudioAnalysisService {
  Stream<AudioFrame> get frames;
  Future<void> start();
  Future<void> stop();
  bool get isListening;
}

class AudioFrame {
  const AudioFrame({
    required this.amplitudes,
    required this.frequencies,
    required this.timestamp,
  });

  final List<double> amplitudes;
  final List<double> frequencies;
  final DateTime timestamp;
}

/// On-device and hybrid diagnosis orchestration.
abstract class AiDiagnosisService {
  Stream<DiagnosisStage> analyze({
    required Vehicle vehicle,
    required Stream<AudioFrame> audioFrames,
  });

  Future<ScanSession> buildSession({
    required Vehicle vehicle,
    required List<DiagnosisStage> stages,
  });
}

class DiagnosisStage {
  const DiagnosisStage({
    required this.label,
    required this.progress,
    this.faults = const [],
  });

  final String label;
  final double progress;
  final List<ComponentFault> faults;
}

/// Future cloud LLM explanations and fleet intelligence.
abstract class CloudAiService {
  Future<String> explainFault(ComponentFault fault, Vehicle vehicle);
  Future<bool> get isAvailable;
}

/// Future OBD-II telemetry bridge.
abstract class ObdService {
  Future<bool> get isConnected;
  Stream<ObdReading> get readings;
  Future<void> connect();
  Future<void> disconnect();
}

class ObdReading {
  const ObdReading({required this.pid, required this.value, required this.unit});
  final String pid;
  final double value;
  final String unit;
}
