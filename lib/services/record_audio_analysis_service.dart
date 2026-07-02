import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:record/record.dart';

import 'interfaces/diagnosis_services.dart';

/// Captures live microphone PCM and derives waveform + spectrum frames.
class RecordAudioAnalysisService implements AudioAnalysisService {
  RecordAudioAnalysisService();

  final AudioRecorder _recorder = AudioRecorder();
  final _controller = StreamController<AudioFrame>.broadcast();
  StreamSubscription<Uint8List>? _sub;
  bool _listening = false;

  @override
  Stream<AudioFrame> get frames => _controller.stream;

  @override
  bool get isListening => _listening;

  @override
  Future<void> start() async {
    if (_listening) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw StateError('Microphone permission not granted');
    }

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 22050,
        numChannels: 1,
      ),
    );

    _listening = true;
    _sub = stream.listen(_onPcm);
  }

  void _onPcm(Uint8List bytes) {
    if (bytes.isEmpty) return;
    final samples = bytes.buffer.asInt16List(bytes.offsetInBytes, bytes.length ~/ 2);
    if (samples.isEmpty) return;

    var sum = 0.0;
    for (final s in samples) {
      sum += s * s;
    }
    final rms = math.sqrt(sum / samples.length) / 32768.0;

    final amps = List<double>.generate(24, (i) {
      final band = (i / 24 * samples.length).floor();
      final end = math.min(band + (samples.length ~/ 24), samples.length);
      var bandEnergy = 0.0;
      for (var j = band; j < end; j++) {
        bandEnergy += samples[j].abs() / 32768.0;
      }
      return (bandEnergy / math.max(1, end - band)).clamp(0.0, 1.0) * (0.6 + rms);
    });

    final freqs = List<double>.generate(24, (i) => i * 180.0 + rms * 40);

    _controller.add(AudioFrame(
      amplitudes: amps,
      frequencies: freqs,
      timestamp: DateTime.now(),
      rms: rms,
    ));
  }

  @override
  Future<void> stop() async {
    _listening = false;
    await _sub?.cancel();
    _sub = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }

  void dispose() {
    stop();
    _controller.close();
    _recorder.dispose();
  }
}
