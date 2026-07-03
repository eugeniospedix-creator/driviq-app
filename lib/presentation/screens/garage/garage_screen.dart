import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/usecase_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/async/dq_async_view.dart';
import '../../widgets/cards/vehicle_garage_card.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/typography/section_header.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garageAsync = ref.watch(garageOverviewProvider);

    return DqPage(
      child: DqAsyncBody(
        asyncValue: garageAsync,
        builder: (overviews) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
            children: [
              const SectionHeader(
                title: 'Garage',
                subtitle: 'Your vehicles, curated in a private showroom.',
              ),
              const SizedBox(height: 22),
              ...overviews.map((overview) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: VehicleGarageCard(
                      vehicle: overview.vehicle,
                      health: overview.health,
                      isPrimary: overview.vehicle.isPrimary,
                      onTap: () async {
                        await ref.read(setPrimaryVehicleUseCaseProvider).execute(overview.vehicle.id);
                        ref.invalidate(primaryVehicleProvider);
                        ref.invalidate(vehiclesProvider);
                        ref.invalidate(garageOverviewProvider);
                      },
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
                                'Add Vehicle',
                                style: TextStyle(
                                  color: DQ.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Identify in Scan',
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
