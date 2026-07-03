import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/enums/fault_severity.dart';
import '../../../domain/entities/component_fault.dart';
import '../../../domain/entities/scan_session.dart';
import '../../../domain/entities/vehicle.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/async/dq_async_view.dart';
import '../../widgets/buttons/dq_button.dart';
import '../../widgets/cards/diagnosis_detail.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/vehicle/driviq_studio_vehicle.dart';

class DiagnosisResultScreen extends ConsumerStatefulWidget {
  const DiagnosisResultScreen({super.key});

  @override
  ConsumerState<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends ConsumerState<DiagnosisResultScreen> {
  ComponentFault? _selected;

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(primaryVehicleProvider);

    return Scaffold(
      backgroundColor: DQ.voidBlack,
      body: DqPage(
        child: DqAsyncBody(
          asyncValue: vehicleAsync,
          builder: (vehicle) {
            if (vehicle == null) {
              return const Center(child: Text('No vehicle', style: TextStyle(color: DQ.textMuted)));
            }
            final scanAsync = ref.watch(latestScanProvider(vehicle.id));
            return DqAsyncBody(
              asyncValue: scanAsync,
              builder: (scan) {
                if (scan == null) {
                  return const Center(child: Text('No diagnosis available', style: TextStyle(color: DQ.textMuted)));
                }
                return _ResultBody(
                  vehicle: vehicle,
                  scan: scan,
                  selected: _selected,
                  onSelect: (f) => setState(() => _selected = f),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.vehicle,
    required this.scan,
    required this.selected,
    required this.onSelect,
  });

  final Vehicle vehicle;
  final ScanSession scan;
  final ComponentFault? selected;
  final ValueChanged<ComponentFault> onSelect;

  @override
  Widget build(BuildContext context) {
    final faults = scan.faults;
    if (faults.isEmpty) {
      return const Center(child: Text('No faults detected', style: TextStyle(color: DQ.textMuted)));
    }

    var active = faults.first;
    if (selected != null) {
      active = selected!;
    } else {
      for (final fault in faults) {
        if (fault.severity == FaultSeverity.attention || fault.severity == FaultSeverity.critical) {
          active = fault;
          break;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
      children: [
        const Text(
          'DIAGNOSIS',
          style: TextStyle(color: DQ.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        Text(
          'Analysis Complete',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Health score ${scan.healthScore} • ${scan.healthStatus.label}',
          style: TextStyle(color: DQ.healthColor(scan.healthScore), fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 280,
          child: DarkPanel(
            padding: const EdgeInsets.all(12),
            child: DriviqStudioVehicle(
              vehicle: vehicle,
              height: 256,
              highlightColor: DQ.healthColor(scan.healthScore),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(child: FaultDetailCard(fault: active)),
        const SizedBox(height: 18),
        DqButton(
          label: 'VIEW FULL REPORT',
          variant: DqButtonVariant.secondary,
          onTap: () => context.go(AppRoutes.report),
        ),
        const SizedBox(height: 12),
        DqButton(
          label: 'DONE',
          onTap: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}
