import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/scan_session.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/vehicle_health.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/async/dq_async_view.dart';
import '../../widgets/buttons/dq_button.dart';
import '../../widgets/health/health_ring.dart';
import '../../widgets/home/ai_neural_status_card.dart';
import '../../widgets/home/last_scan_card.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/vehicle/interactive_vehicle_viewer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  double _parallax = 0;
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => setState(() => _parallax = _scroll.offset));
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _quickScan() async {
    final canScan = ref.read(canRunScanProvider);
    if (!canScan) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enable microphone and AI in Settings.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final granted = await ref.read(microphonePermissionServiceProvider).isGranted;
    if (!mounted) return;
    if (granted) {
      context.push(AppRoutes.scanRunning);
    } else {
      context.push(AppRoutes.scanPermission);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(primaryVehicleProvider);

    return DqPage(
      child: DqAsyncBody(
        asyncValue: vehicleAsync,
        builder: (vehicle) {
          if (vehicle == null) {
            return Center(
              child: DqButton(label: 'ADD YOUR FIRST VEHICLE', onTap: () => context.go(AppRoutes.garage)),
            );
          }

          final healthAsync = ref.watch(vehicleHealthProvider(vehicle.id));
          final scanAsync = ref.watch(latestScanProvider(vehicle.id));

          return DqAsyncBody(
            asyncValue: healthAsync,
            builder: (health) => _CinematicBody(
              scroll: _scroll,
              parallax: _parallax,
              entrance: _entrance,
              vehicle: vehicle,
              health: health,
              scan: scanAsync.value,
              onQuickScan: _quickScan,
            ),
          );
        },
      ),
    );
  }
}

class _CinematicBody extends StatelessWidget {
  const _CinematicBody({
    required this.scroll,
    required this.parallax,
    required this.entrance,
    required this.vehicle,
    required this.health,
    required this.scan,
    required this.onQuickScan,
  });

  final ScrollController scroll;
  final double parallax;
  final AnimationController entrance;
  final Vehicle vehicle;
  final VehicleHealth health;
  final ScanSession? scan;
  final VoidCallback onQuickScan;

  @override
  Widget build(BuildContext context) {
    final heroOffset = parallax * 0.18;
    final glowOffset = parallax * 0.08;
    final fade = CurvedAnimation(parent: entrance, curve: Curves.easeOutCubic);

    return FadeTransition(
      opacity: fade,
      child: ListView(
        controller: scroll,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName.toUpperCase(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 38),
                    ),
                    const SizedBox(height: 6),
                    Text(AppConstants.appTagline, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DQ.graphite3,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DQ.cyan.withValues(alpha: 0.3)),
                  boxShadow: [BoxShadow(color: DQ.cyan.withValues(alpha: 0.2), blurRadius: 22)],
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: DQ.cyan, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Transform.translate(
            offset: Offset(0, heroOffset),
            child: DarkPanel(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
              glowColor: DQ.healthColor(health.score),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: const TextStyle(
                      color: DQ.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.year} • ${vehicle.mileageKm ?? 0} km',
                    style: const TextStyle(color: DQ.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: Stack(
                      children: [
                        Transform.translate(
                          offset: Offset(0, glowOffset),
                          child: Center(
                            child: Container(
                              width: 280,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: DQ.cyan.withValues(alpha: 0.16),
                                    blurRadius: 60,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InteractiveVehicleViewer(
                          vehicle: vehicle,
                          height: 300,
                          showGlow: true,
                          faults: scan?.faults ?? const [],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HealthRing(score: health.score, status: health.status, size: 112),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            LastScanCard(health: health, scan: scan),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: DQ.healthColor(health.score).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(DQ.radiusMd),
                                border: Border.all(color: DQ.healthColor(health.score).withValues(alpha: 0.25)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    health.status.label,
                                    style: TextStyle(
                                      color: DQ.healthColor(health.score),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    health.summary,
                                    style: const TextStyle(color: DQ.textSecondary, fontSize: 13, height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  DqButton(label: 'QUICK SCAN', icon: Icons.mic_rounded, onTap: onQuickScan),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Transform.translate(
            offset: Offset(0, parallax * 0.05),
            child: const AiNeuralStatusCard(),
          ),
        ],
      ),
    );
  }
}
