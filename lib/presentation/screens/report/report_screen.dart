import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/async/dq_async_view.dart';
import '../../widgets/cards/diagnosis_detail.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/typography/section_header.dart';
import '../../widgets/vehicle/driviq_studio_vehicle.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(primaryVehicleProvider);
    final selectedId = ref.watch(selectedFaultIdProvider);

    return DqPage(
      child: DqAsyncBody(
        asyncValue: vehicleAsync,
        builder: (vehicle) {
          if (vehicle == null) {
            return const Center(
              child: Text('No vehicle selected', style: TextStyle(color: DQ.textMuted)),
            );
          }

          final scanAsync = ref.watch(latestScanProvider(vehicle.id));
          return DqAsyncBody(
            asyncValue: scanAsync,
            builder: (scan) {
              if (scan == null) {
                return const Center(
                  child: Text('Run a scan to generate your report', style: TextStyle(color: DQ.textMuted)),
                );
              }

              final faults = scan.faults;
              if (faults.isEmpty) {
                return const Center(
                  child: Text('No component data in this scan', style: TextStyle(color: DQ.textMuted)),
                );
              }

              var selected = faults.first;
              if (selectedId != null) {
                selected = faults.firstWhere((f) => f.id == selectedId, orElse: () => faults.first);
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
                children: [
                  const SectionHeader(
                    title: 'Report',
                    subtitle: 'Component-level intelligence interpretation.',
                  ),
                  const SizedBox(height: 22),
                  DarkPanel(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    child: DriviqStudioVehicle(
                      vehicle: vehicle,
                      height: 280,
                      highlightColor: DQ.healthColor(scan.healthScore),
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassPanel(child: FaultDetailCard(fault: selected)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
