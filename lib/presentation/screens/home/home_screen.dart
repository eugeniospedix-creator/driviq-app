import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/async/dq_async_view.dart';
import '../../widgets/buttons/dq_button.dart';
import '../../widgets/health/health_ring.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/typography/section_header.dart';
import '../../widgets/vehicle/vehicle_viewer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(primaryVehicleProvider);

    return DqPage(
      child: DqAsyncBody(
        asyncValue: vehicleAsync,
        builder: (vehicle) {
          if (vehicle == null) {
            return Center(
              child: DqButton(
                label: 'ADD YOUR FIRST VEHICLE',
                onTap: () => context.go(AppRoutes.garage),
              ),
            );
          }

          final healthAsync = ref.watch(vehicleHealthProvider(vehicle.id));
          final scanAsync = ref.watch(latestScanProvider(vehicle.id));

          return DqAsyncBody(
            asyncValue: healthAsync,
            builder: (health) {
              final faults = scanAsync.value?.faults ?? const [];
              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
                children: [
                  FadeSlideIn(
                    child: SectionHeader(
                      title: AppConstants.appName.toUpperCase(),
                      subtitle: AppConstants.appTagline,
                      trailing: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: DQ.graphite3,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: DQ.cyan.withValues(alpha: 0.25)),
                          boxShadow: [BoxShadow(color: DQ.cyan.withValues(alpha: 0.15), blurRadius: 20)],
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: DQ.cyan, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: DarkPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.displayName,
                            style: const TextStyle(
                              color: DQ.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vehicle.year} • ${vehicle.mileageKm ?? 0} km',
                            style: const TextStyle(color: DQ.textMuted, fontSize: 15),
                          ),
                          const SizedBox(height: 16),
                          VehicleViewer(
                            vehicle: vehicle,
                            height: 280,
                            faults: faults,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              HealthRing(score: health.score, status: health.status),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(DQ.radiusMd),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        health.status.label,
                                        style: TextStyle(
                                          color: DQ.healthColor(health.score),
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        health.summary,
                                        style: const TextStyle(color: DQ.textSecondary, height: 1.35, fontSize: 14),
                                      ),
                                      if (health.trendDelta != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          '${health.trendDelta! >= 0 ? '+' : ''}${health.trendDelta} since last scan',
                                          style: TextStyle(
                                            color: health.trendDelta! >= 0 ? DQ.emerald : DQ.amber,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                      if (health.lastScanAt != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Last scan ${DateFormat.MMMd().add_jm().format(health.lastScanAt!)}',
                                          style: const TextStyle(color: DQ.textMuted, fontSize: 12),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          DqButton(
                            label: 'QUICK SCAN',
                            icon: Icons.radar_rounded,
                            onTap: () => context.go(AppRoutes.scan),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 160),
                    child: GlassPanel(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: DQ.cyanSoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.psychology_rounded, color: DQ.cyan, size: 26),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Neural Engine is learning your vehicle baseline from repeated scans.',
                              style: TextStyle(
                                color: DQ.textPrimary,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
