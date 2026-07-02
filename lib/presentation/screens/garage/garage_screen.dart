import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../providers/repository_providers.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/cards/vehicle_garage_card.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/typography/section_header.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return DqPage(
      child: vehiclesAsync.when(
        loading: () => const Center(child: DqLoadingShell()),
        error: (e, _) => Center(child: Text('Unable to load garage', style: TextStyle(color: DQ.coral))),
        data: (vehicles) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
            children: [
              const FadeSlideIn(
                child: SectionHeader(
                  title: 'Garage',
                  subtitle: 'A digital vehicle room for every car you own.',
                ),
              ),
              const SizedBox(height: 22),
              ...vehicles.asMap().entries.map((entry) {
                final i = entry.key;
                final vehicle = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FadeSlideIn(
                    delay: Duration(milliseconds: 60 * i),
                    child: _GarageVehicleTile(vehicleId: vehicle.id),
                  ),
                );
              }),
              FadeSlideIn(
                delay: Duration(milliseconds: 60 * vehicles.length),
                child: GestureDetector(
                  onTap: () {
                    // Phase 2: add-vehicle flow
                  },
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
                                'Add Vehicle',
                                style: TextStyle(
                                  color: DQ.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Manual entry or VIN lookup',
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
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GarageVehicleTile extends ConsumerWidget {
  const _GarageVehicleTile({required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final healthAsync = ref.watch(vehicleHealthProvider(vehicleId));

    final vehicle = vehiclesAsync.value?.where((v) => v.id == vehicleId).firstOrNull;
    if (vehicle == null) return const SizedBox.shrink();

    return healthAsync.when(
      loading: () => const SizedBox(height: 200),
      error: (_, __) => const SizedBox.shrink(),
      data: (health) => VehicleGarageCard(
        vehicle: vehicle,
        health: health,
        onTap: () async {
          await ref.read(vehicleRepositoryProvider).setPrimary(vehicle.id);
          ref.invalidate(primaryVehicleProvider);
          ref.invalidate(vehiclesProvider);
        },
      ),
    );
  }
}
