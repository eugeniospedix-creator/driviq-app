import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/usecase_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/home_weather_context.dart';
import '../../providers/vehicle_providers.dart';
import '../../providers/weather_providers.dart';
import '../../widgets/async/dq_async_view.dart';
import '../../widgets/buttons/dq_button.dart';
import '../../widgets/cards/vehicle_garage_card.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/typography/section_header.dart';
import '../../widgets/vehicle/vehicle_photo_capture.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garageAsync = ref.watch(garageOverviewProvider);
    final weather = ref.watch(homeWeatherContextProvider).asData?.value ?? HomeWeatherContext.fallback;

    return DqPage(
      child: DqAsyncBody(
        asyncValue: garageAsync,
        builder: (overviews) {
          if (overviews.isEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Garage',
                    subtitle: 'Your vehicles live here — photos, scans, and health history.',
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'No vehicles yet',
                      style: TextStyle(color: DQ.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Add your car in Scan to build your garage.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: DQ.textMuted, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 28),
                  DqButton(
                    label: 'GO TO SCAN',
                    icon: Icons.directions_car_filled_rounded,
                    onTap: () => context.go(AppRoutes.scan),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
            children: [
              const SectionHeader(
                title: 'Garage',
                subtitle: 'Your vehicles — real photos, scan history, and health.',
              ),
              const SizedBox(height: 22),
              ...overviews.map((overview) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      VehicleGarageCard(
                        vehicle: overview.vehicle,
                        health: overview.health,
                        isPrimary: overview.vehicle.isPrimary,
                        mood: weather.mood,
                        weatherEffectsEnabled: weather.showEffects,
                        onTap: () async {
                          await ref.read(setPrimaryVehicleUseCaseProvider).execute(overview.vehicle.id);
                          ref.invalidate(primaryVehicleProvider);
                          ref.invalidate(vehiclesProvider);
                          ref.invalidate(garageOverviewProvider);
                        },
                        onPhotoTap: () async {
                          await captureVehiclePhotoFlow(
                            context: context,
                            ref: ref,
                            vehicle: overview.vehicle,
                          );
                          ref.invalidate(garageOverviewProvider);
                          ref.invalidate(primaryVehicleProvider);
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => context.push(AppRoutes.createVehicle3D, extra: overview.vehicle),
                          icon: const Icon(Icons.view_in_ar_rounded, size: 18),
                          label: const Text(
                            'Create your 3D vehicle',
                            style: TextStyle(decoration: TextDecoration.none, decorationThickness: 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              GestureDetector(
                onTap: () => context.go(AppRoutes.scan),
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
                        child: const Icon(Icons.add_rounded, color: DQ.cyan, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add vehicle',
                              style: TextStyle(
                                color: DQ.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Set up in Scan',
                              style: TextStyle(color: DQ.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: DQ.textMuted.withValues(alpha: 0.6)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
