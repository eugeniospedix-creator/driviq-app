import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/interfaces/diagnosis_services.dart';
import '../../providers/repository_providers.dart';
import 'scan_visuals.dart';

/// Isolates high-frequency audio updates from the rest of the scan screen.
class ScanWaveformPanel extends ConsumerStatefulWidget {
  const ScanWaveformPanel({super.key});

  @override
  ConsumerState<ScanWaveformPanel> createState() => _ScanWaveformPanelState();
}

class _ScanWaveformPanelState extends ConsumerState<ScanWaveformPanel> {
  List<double> _amps = List.filled(24, 0.1);
  StreamSubscription<AudioFrame>? _sub;
  DateTime _lastPaint = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    final audio = ref.read(audioAnalysisServiceProvider);
    _sub = audio.frames.listen(_onFrame);
  }

  void _onFrame(AudioFrame frame) {
    final now = DateTime.now();
    if (now.difference(_lastPaint).inMilliseconds < 80) return;
    _lastPaint = now;
    if (!mounted) return;
    setState(() => _amps = frame.amplitudes);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AudioWaveform(amplitudes: _amps);
}
