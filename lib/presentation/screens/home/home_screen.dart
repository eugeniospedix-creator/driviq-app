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
import '../../widgets/home/last_scan_card.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/home/home_vehicle_hero.dart';

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
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
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
    final screenHeight = MediaQuery.sizeOf(context).height;

    return DqPage(
      padding: EdgeInsets.zero,
      child: DqAsyncBody(
        asyncValue: vehicleAsync,
        builder: (vehicle) {
          if (vehicle == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your vehicle awaits',
                      style: TextStyle(
                        color: DQ.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Identify your car to unlock acoustic intelligence.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: DQ.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 28),
                    DqButton(label: 'IDENTIFY VEHICLE', onTap: () => context.go(AppRoutes.scan)),
                  ],
                ),
              ),
            );
          }

          final healthAsync = ref.watch(vehicleHealthProvider(vehicle.id));
          final scanAsync = ref.watch(latestScanProvider(vehicle.id));

          return DqAsyncBody(
            asyncValue: healthAsync,
            builder: (health) => _CinematicHome(
              scroll: _scroll,
              parallax: _parallax,
              entrance: _entrance,
              heroHeight: screenHeight * 0.72,
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

class _CinematicHome extends StatelessWidget {
  const _CinematicHome({
    required this.scroll,
    required this.parallax,
    required this.entrance,
    required this.heroHeight,
    required this.vehicle,
    required this.health,
    required this.scan,
    required this.onQuickScan,
  });

  final ScrollController scroll;
  final double parallax;
  final AnimationController entrance;
  final double heroHeight;
  final Vehicle vehicle;
  final VehicleHealth health;
  final ScanSession? scan;
  final VoidCallback onQuickScan;

  @override
  Widget build(BuildContext context) {
    final healthColor = DQ.healthColor(health.score);
    final fade = CurvedAnimation(parent: entrance, curve: Curves.easeOutCubic);
    final heroShift = parallax * 0.18;

    return FadeTransition(
      opacity: fade,
      child: CustomScrollView(
        controller: scroll,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.translate(
                    offset: Offset(0, heroShift),
                    child: HomeVehicleHero(
                      vehicle: vehicle,
                      height: heroHeight,
                      highlightColor: healthColor,
                    ),
                  ),
                  Positioned(
                    top: 18,
                    left: 22,
                    right: 22,
                    child: Row(
                      children: [
                        Text(
                          AppConstants.appName.toUpperCase(),
                          style: const TextStyle(
                            color: DQ.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: DQ.voidBlack.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: healthColor.withValues(alpha: 0.4)),
                            boxShadow: [
                              BoxShadow(color: healthColor.withValues(alpha: 0.12), blurRadius: 18),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: healthColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: healthColor.withValues(alpha: 0.7), blurRadius: 10)],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                health.status.label.toUpperCase(),
                                style: TextStyle(
                                  color: healthColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 110,
                    bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: DQ.textPrimary,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.3,
                            height: 1.02,
                            shadows: [
                              Shadow(color: Color(0xCC05080C), blurRadius: 24, offset: Offset(0, 8)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${vehicle.year} • ${vehicle.mileageKm ?? 0} km',
                          style: const TextStyle(
                            color: DQ.textSecondary,
                            fontSize: 15,
                            shadows: [Shadow(color: Color(0x9905080C), blurRadius: 12)],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 22,
                    bottom: 22,
                    child: HealthRing(score: health.score, status: health.status, size: 92),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        healthColor.withValues(alpha: 0.10),
                        DQ.graphite2.withValues(alpha: 0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(DQ.radiusLg),
                    border: Border.all(color: healthColor.withValues(alpha: 0.22)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        health.status.label,
                        style: TextStyle(
                          color: healthColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        health.summary,
                        style: const TextStyle(color: DQ.textSecondary, fontSize: 14, height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LastScanCard(health: health, scan: scan),
                const SizedBox(height: 18),
                DqButton(label: 'BEGIN ANALYSIS', icon: Icons.mic_rounded, onTap: onQuickScan),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.scan),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(DQ.radiusMd),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tune_rounded, color: DQ.textSecondary, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Change vehicle identity',
                            style: TextStyle(color: DQ.textSecondary, fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: DQ.textMuted, size: 22),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
