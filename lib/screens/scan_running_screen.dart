import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/digital_twin.dart';
import 'report_screen.dart';

class ScanRunningScreen extends StatefulWidget {
  const ScanRunningScreen({super.key});

  @override
  State<ScanRunningScreen> createState() => _ScanRunningScreenState();
}

class _ScanRunningScreenState extends State<ScanRunningScreen> {
  double p = 0;
  int step = 0;

  final steps = const [
    'Microphone ready',
    'Accelerometer ready',
    'Gyroscope ready',
    'Acoustic anomaly scan',
    'Structural vibration map',
    'Component correlation',
  ];

  @override
  void initState() {
    super.initState();
    run();
  }

  Future<void> run() async {
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 45));
      if (!mounted) return;
      setState(() {
        p = i / 100;
        step = ((p * steps.length).floor()).clamp(0, steps.length - 1);
      });
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ReportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DQ.graphite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'DRIVIQ CORE',
                style: TextStyle(
                  color: Colors.white54,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 28),
              const Expanded(
                child: DigitalTwin(
                  dark: true,
                  interactive: false,
                  scanning: true,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                steps[step],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Do not interact while driving.',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 28),
              LinearProgressIndicator(
                value: p,
                minHeight: 10,
                borderRadius: BorderRadius.circular(99),
                backgroundColor: Colors.white12,
                color: DQ.cyan,
              ),
              const SizedBox(height: 16),
              Text(
                '${(p * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
