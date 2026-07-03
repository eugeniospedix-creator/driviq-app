import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/catalog/report_component_mapper.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/home_weather_context.dart';
import '../../providers/vehicle_model_providers.dart';
import '../../providers/vehicle_providers.dart';
import '../../providers/weather_providers.dart';
import '../../widgets/async/dq_async_view.dart';
import '../../widgets/cards/diagnosis_detail.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/typography/section_header.dart';
import '../../widgets/vehicle/component_detail_sheet.dart';
import '../../widgets/vehicle/driviq_studio_vehicle.dart';
import '../../widgets/vehicle/vehicle_photo_capture.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(primaryVehicleProvider);
    final selectedId = ref.watch(selectedFaultIdProvider);
    final weather = ref.watch(homeWeatherContextProvider).asData?.value ?? HomeWeatherContext.fallback;

    return DqPage(
      child: DqAsyncBody(
        asyncValue: vehicleAsync,
        builder: (vehicle) {
          if (vehicle == null) {
            return const Center(
              child: Text('Add a vehicle in Scan to view your report', style: TextStyle(color: DQ.textMuted)),
            );
          }

          final scanAsync = ref.watch(latestScanProvider(vehicle.id));
          return DqAsyncBody(
            asyncValue: scanAsync,
            builder: (scan) {
              if (scan == null) {
                return const Center(
                  child: Text('Run an acoustic scan to generate your report', style: TextStyle(color: DQ.textMuted)),
                );
              }

              final hotspots = ReportComponentMapper.hotspotsForReport(scan.faults);
              var selected = hotspots.first;
              if (selectedId != null) {
                selected = hotspots.firstWhere((f) => f.id == selectedId, orElse: () => hotspots.first);
              }

              final modelAsset = ref.watch(vehicleModelAssetProvider(vehicle.id));

              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
                children: [
                  const SectionHeader(
                    title: 'Report',
                    subtitle: 'Component map on your vehicle photo.',
                  ),
                  const SizedBox(height: 22),
                  DarkPanel(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: DriviqStudioVehicle(
                      vehicle: vehicle,
                      height: 340,
                      highlightColor: DQ.healthColor(scan.healthScore),
                      interactive: true,
                      mood: weather.mood,
                      weatherEffectsEnabled: weather.showEffects,
                      faults: hotspots,
                      highlightedFault: selected,
                      onFaultSelected: (fault) {
                        ref.read(selectedFaultIdProvider.notifier).state = fault.id;
                        ComponentDetailSheet.show(
                          context,
                          vehicle: vehicle,
                          componentId: fault.componentId,
                          fault: _faultForComponent(scan.faults, fault.componentId),
                          glbPath: modelAsset.asData?.value.glbPath,
                        );
                      },
                      onAddPhoto: () => captureVehiclePhotoFlow(
                        context: context,
                        ref: ref,
                        vehicle: vehicle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassPanel(child: FaultDetailCard(fault: selected)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.createVehicle3D, extra: vehicle),
                    child: const Text(
                      'Create your 3D vehicle',
                      style: TextStyle(
                        color: DQ.textMuted,
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
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

ComponentFault? _faultForComponent(List<ComponentFault> faults, String componentId) {
  for (final fault in faults) {
    if (fault.componentId == componentId) return fault;
  }
  return null;
}
