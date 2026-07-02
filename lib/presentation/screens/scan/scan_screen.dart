import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/usecase_providers.dart';
import '../../../application/usecases/save_vehicle_profile_usecase.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/errors/app_exception.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';
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
    try {
      final vehicle = await ref.read(saveVehicleProfileUseCaseProvider).execute(
            SaveVehicleProfileInput(
              existingId: _previewVehicle?.id,
              make: _make.text,
              model: _model.text,
              year: int.tryParse(_year.text.trim()) ?? DateTime.now().year,
              isPrimary: _previewVehicle?.isPrimary ?? true,
              createdAt: _previewVehicle?.createdAt,
            ),
          );

      ref.invalidate(vehiclesProvider);
      ref.invalidate(primaryVehicleProvider);
      ref.invalidate(garageOverviewProvider);

      setState(() {
        _previewVehicle = vehicle;
        _profileReady = true;
      });
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _startScan() {
    final canScan = ref.read(canRunScanProvider);
    if (!canScan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable microphone and AI in Settings to start a scan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Future<void>(() async {
      final granted = await ref.read(microphonePermissionServiceProvider).isGranted;
      if (!mounted) return;
      if (granted) {
        context.push(AppRoutes.scanRunning);
      } else {
        context.push(AppRoutes.scanPermission);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _previewVehicle;
    final canScan = ref.watch(canRunScanProvider);

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
                    InteractiveVehicleViewer(vehicle: vehicle, height: 240)
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
            enabled: _profileReady && canScan,
            onTap: _profileReady && canScan ? _startScan : null,
          ),
        ],
      ),
    );
  }
}
