import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/async/dq_async_view.dart';
import '../../widgets/cards/diagnosis_detail.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/typography/section_header.dart';
import '../../widgets/vehicle/vehicle_viewer.dart';

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
                  const FadeSlideIn(
                    child: SectionHeader(
                      title: 'Report',
                      subtitle: 'Component-level intelligence interpretation.',
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: DarkPanel(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                      child: Column(
                        children: [
                          VehicleViewer(
                            vehicle: vehicle,
                            height: 300,
                            interactive: true,
                            faults: faults,
                            highlightedFault: selected,
                            onFaultSelected: (f) =>
                                ref.read(selectedFaultIdProvider.notifier).state = f.id,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tap a component to inspect',
                            style: TextStyle(color: DQ.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 140),
                    child: GlassPanel(child: FaultDetailCard(fault: selected)),
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
