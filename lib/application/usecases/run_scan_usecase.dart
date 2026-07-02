import '../../domain/entities/scan_session.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/errors/app_exception.dart';
import '../../domain/extensions/app_settings_scan.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../services/interfaces/diagnosis_services.dart';

/// Orchestrates the full scan pipeline — settings gate, audio lifecycle, persistence.
class RunScanUseCase {
  RunScanUseCase({
    required AiDiagnosisService ai,
    required AudioAnalysisService audio,
    required DiagnosisRepository diagnosis,
    required SettingsRepository settings,
  })  : _ai = ai,
        _audio = audio,
        _diagnosis = diagnosis,
        _settings = settings;

  final AiDiagnosisService _ai;
  final AudioAnalysisService _audio;
  final DiagnosisRepository _diagnosis;
  final SettingsRepository _settings;

  Stream<AudioFrame> get audioFrames => _audio.frames;

  Future<void> _ensureScanAllowed() async {
    final settings = await _settings.get();
    if (!settings.canRunScan()) {
      throw const ScanNotAllowedException(
        'Enable microphone and at least one AI engine in Settings to run a scan.',
      );
    }
  }

  Stream<DiagnosisStage> analyze(Vehicle vehicle) async* {
    await _ensureScanAllowed();
    await _audio.start();
    try {
      yield* _ai.analyze(vehicle: vehicle, audioFrames: _audio.frames);
    } finally {
      await _audio.stop();
    }
  }

  Future<ScanSession> complete(Vehicle vehicle, List<DiagnosisStage> stages) async {
    try {
      final session = await _ai.buildSession(vehicle: vehicle, stages: stages);
      await _diagnosis.save(session);
      return session;
    } catch (_) {
      throw const PersistenceException('Scan completed but results could not be saved.');
    }
  }

  Future<void> cancel() => _audio.stop();
}
