import 'dart:async';

import 'interfaces/diagnosis_services.dart';
import 'local_diagnosis_service.dart';
import 'record_audio_analysis_service.dart';

/// Uses live microphone when available; falls back to simulated frames in simulator/dev.
class HybridAudioAnalysisService implements AudioAnalysisService {
  HybridAudioAnalysisService({
    required RecordAudioAnalysisService real,
    required SimulatedAudioAnalysisService simulated,
  })  : _real = real,
        _simulated = simulated;

  final RecordAudioAnalysisService _real;
  final SimulatedAudioAnalysisService _simulated;
  AudioAnalysisService? _active;

  @override
  Stream<AudioFrame> get frames => (_active ?? _simulated).frames;

  @override
  bool get isListening => _active?.isListening ?? false;

  @override
  Future<void> start() async {
    try {
      await _real.start();
      _active = _real;
    } catch (_) {
      await _simulated.start();
      _active = _simulated;
    }
  }

  @override
  Future<void> stop() async {
    await _real.stop();
    await _simulated.stop();
    _active = null;
  }

  void dispose() {
    _real.dispose();
    _simulated.dispose();
  }
}
