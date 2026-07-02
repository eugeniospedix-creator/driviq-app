import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../data/catalog/vehicle_catalog.dart';
import '../../../domain/entities/vehicle.dart';
import '../../providers/repository_providers.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/buttons/dq_button.dart';
import '../../widgets/inputs/dq_text_field.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/typography/section_header.dart';
import '../../widgets/vehicle/vehicle_viewer.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  late final TextEditingController _make;
  late final TextEditingController _model;
  late final TextEditingController _year;
  Vehicle? _previewVehicle;
  bool _profileReady = false;

  @override
  void initState() {
    super.initState();
    _make = TextEditingController();
    _model = TextEditingController();
    _year = TextEditingController();
    _loadPrimary();
  }

  Future<void> _loadPrimary() async {
    final primary = await ref.read(primaryVehicleProvider.future);
    if (!mounted || primary == null) return;
    _make.text = primary.make;
    _model.text = primary.model;
    _year.text = '${primary.year}';
    setState(() {
      _previewVehicle = primary;
      _profileReady = true;
    });
  }

  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final make = _make.text.trim();
    final model = _model.text.trim();
    final year = int.tryParse(_year.text.trim()) ?? DateTime.now().year;
    final catalog = VehicleCatalog.resolve(make, model);
    final assetKey = catalog?.assetKey ?? 'generic_sedan';

    final vehicle = Vehicle(
      id: _previewVehicle?.id ?? const Uuid().v4(),
      make: make,
      model: model,
      year: year,
      modelAssetKey: assetKey,
      isPrimary: _previewVehicle?.isPrimary ?? true,
      createdAt: _previewVehicle?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(vehicleRepositoryProvider).save(vehicle);
    ref.invalidate(vehiclesProvider);
    ref.invalidate(primaryVehicleProvider);

    setState(() {
      _previewVehicle = vehicle;
      _profileReady = make.isNotEmpty && model.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _previewVehicle;

    return DqPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
        children: [
          const FadeSlideIn(
            child: SectionHeader(
              title: 'Smart Scan',
              subtitle: 'Load your vehicle profile before component analysis.',
            ),
          ),
          const SizedBox(height: 22),
          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicle Passport',
                    style: TextStyle(color: DQ.textPrimary, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),
                  DqTextField(controller: _make, label: 'Make'),
                  const SizedBox(height: 14),
                  DqTextField(controller: _model, label: 'Model'),
                  const SizedBox(height: 14),
                  DqTextField(controller: _year, label: 'Year', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  DqButton(
                    label: 'LOAD VERIFIED PROFILE',
                    variant: DqButtonVariant.secondary,
                    onTap: _loadProfile,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            delay: const Duration(milliseconds: 120),
            child: DarkPanel(
              child: Column(
                children: [
                  if (vehicle != null)
                    VehicleViewer(vehicle: vehicle, height: 240)
                  else
                    const SizedBox(height: 240),
                  const SizedBox(height: 16),
                  Text(
                    _profileReady ? 'Digital Twin Ready' : 'Awaiting Profile',
                    style: const TextStyle(
                      color: DQ.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profileReady
                        ? '${_make.text} ${_model.text} ${_year.text} prepared for acoustic + structural scan.'
                        : 'Enter vehicle details to prepare analysis.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: DQ.textMuted, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          DqButton(
            label: 'START COMPONENT SCAN',
            icon: Icons.mic_rounded,
            enabled: _profileReady,
            onTap: _profileReady ? () => context.push(AppRoutes.scanRunning) : null,
          ),
        ],
      ),
    );
  }
}
