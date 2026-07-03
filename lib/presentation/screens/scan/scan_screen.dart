import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../application/providers/usecase_providers.dart';
import '../../../application/usecases/save_vehicle_profile_usecase.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/catalog/vehicle_catalog.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/vehicle_catalog_entry.dart';
import '../../../domain/errors/app_exception.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/buttons/dq_button.dart';
import '../../widgets/inputs/dq_text_field.dart';
import '../../widgets/scan/vehicle_identity_picker.dart';
import '../../widgets/vehicle/vehicle_hero_stage.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> with SingleTickerProviderStateMixin {
  static const _uuid = Uuid();

  VehicleCatalogEntry? _selectedEntry;
  int _year = VehicleCatalog.bmwM340i.defaultYear;
  Vehicle? _previewVehicle;
  bool _customMode = false;
  bool _saving = false;

  late final TextEditingController _customMake;
  late final TextEditingController _customModel;
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _customMake = TextEditingController();
    _customModel = TextEditingController();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _loadPrimary();
  }

  Future<void> _loadPrimary() async {
    final primary = await ref.read(primaryVehicleProvider.future);
    if (!mounted || primary == null) {
      _selectCatalogEntry(VehicleCatalog.bmwM340i);
      return;
    }

    final catalog = VehicleCatalog.byAssetKey(primary.modelAssetKey) ??
        VehicleCatalog.resolve(primary.make, primary.model) ??
        VehicleCatalog.bmwM340i;

    setState(() {
      _selectedEntry = catalog;
      _year = primary.year;
      _previewVehicle = primary;
      _customMode = false;
    });
  }

  @override
  void dispose() {
    _customMake.dispose();
    _customModel.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _selectCatalogEntry(VehicleCatalogEntry entry) {
    setState(() {
      _customMode = false;
      _selectedEntry = entry;
      _year = entry.defaultYear;
      _previewVehicle = _buildPreview(
        make: entry.make,
        model: entry.model,
        year: entry.defaultYear,
        assetKey: entry.assetKey,
      );
    });
  }

  void _selectYear(int year) {
    setState(() {
      _year = year;
      if (_customMode) {
        _previewVehicle = _buildPreview(
          make: _customMake.text,
          model: _customModel.text,
          year: year,
          assetKey: VehicleCatalog.resolveOrDefault(_customMake.text, _customModel.text).assetKey,
        );
      } else if (_selectedEntry != null) {
        _previewVehicle = _buildPreview(
          make: _selectedEntry!.make,
          model: _selectedEntry!.model,
          year: year,
          assetKey: _selectedEntry!.assetKey,
        );
      }
    });
  }

  void _activateCustomMode() {
    setState(() {
      _customMode = true;
      _customMake.text = _previewVehicle?.make ?? '';
      _customModel.text = _previewVehicle?.model ?? '';
      _previewVehicle = _buildPreview(
        make: _customMake.text,
        model: _customModel.text,
        year: _year,
        assetKey: VehicleCatalog.resolveOrDefault(_customMake.text, _customModel.text).assetKey,
      );
    });
  }

  void _updateCustomPreview() {
    if (!_customMode) return;
    setState(() {
      _previewVehicle = _buildPreview(
        make: _customMake.text,
        model: _customModel.text,
        year: _year,
        assetKey: VehicleCatalog.resolveOrDefault(_customMake.text, _customModel.text).assetKey,
      );
    });
  }

  Vehicle _buildPreview({
    required String make,
    required String model,
    required int year,
    required String assetKey,
  }) {
    final now = DateTime.now();
    return Vehicle(
      id: _previewVehicle?.id ?? _uuid.v4(),
      make: make.trim().isEmpty ? 'Your' : make.trim(),
      model: model.trim().isEmpty ? 'Vehicle' : model.trim(),
      year: year,
      modelAssetKey: assetKey,
      isPrimary: true,
      createdAt: _previewVehicle?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _beginScan() async {
    final canScan = ref.read(canRunScanProvider);
    if (!canScan) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable microphone and AI in Settings to begin analysis.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final vehicle = _previewVehicle;
    if (vehicle == null) return;

    setState(() => _saving = true);
    try {
      final saved = await ref.read(saveVehicleProfileUseCaseProvider).execute(
            SaveVehicleProfileInput(
              existingId: vehicle.id,
              make: vehicle.make,
              model: vehicle.model,
              year: vehicle.year,
              isPrimary: true,
              createdAt: vehicle.createdAt,
            ),
          );

      ref.invalidate(vehiclesProvider);
      ref.invalidate(primaryVehicleProvider);
      ref.invalidate(garageOverviewProvider);

      if (!mounted) return;
      final granted = await ref.read(microphonePermissionServiceProvider).isGranted;
      if (!mounted) return;
      if (granted) {
        context.push(AppRoutes.scanRunning);
      } else {
        context.push(AppRoutes.scanPermission);
      }
      setState(() => _previewVehicle = saved);
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _previewVehicle;
    final canScan = ref.watch(canRunScanProvider);
    final fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DQ.voidBlack, DQ.graphite, DQ.graphite2],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (vehicle != null)
            FadeTransition(
              opacity: fade,
              child: Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) => VehicleHeroStage(
                    vehicle: vehicle,
                    height: constraints.maxHeight,
                    highlightColor: DQ.cyan,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    DQ.voidBlack.withValues(alpha: 0.15),
                    Colors.transparent,
                    DQ.voidBlack.withValues(alpha: 0.88),
                    DQ.voidBlack,
                  ],
                  stops: const [0.0, 0.28, 0.72, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(22, 8, 22, 0),
                  child: Text(
                    'Vehicle Identity',
                    style: TextStyle(
                      color: DQ.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                if (vehicle != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                    child: FadeTransition(
                      opacity: fade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.displayName,
                            style: const TextStyle(
                              color: DQ.textPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.1,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_year • Acoustic twin ready',
                            style: const TextStyle(color: DQ.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                FadeTransition(
                  opacity: fade,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(22, 22, 22, 18 + bottomInset),
                    decoration: BoxDecoration(
                      color: DQ.graphite.withValues(alpha: 0.94),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(DQ.radiusXl)),
                      border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 40,
                          offset: const Offset(0, -12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VehicleIdentityPicker(
                          selected: _selectedEntry,
                          year: _year,
                          customActive: _customMode,
                          onCatalogSelected: _selectCatalogEntry,
                          onYearSelected: _selectYear,
                          onCustomTap: _activateCustomMode,
                        ),
                        if (_customMode) ...[
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: DqTextField(
                                  controller: _customMake,
                                  label: 'Make',
                                  onChanged: (_) => _updateCustomPreview(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DqTextField(
                                  controller: _customModel,
                                  label: 'Model',
                                  onChanged: (_) => _updateCustomPreview(),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 22),
                        DqButton(
                          label: _saving ? 'PREPARING…' : 'BEGIN ANALYSIS',
                          icon: Icons.mic_rounded,
                          enabled: vehicle != null && canScan && !_saving,
                          onTap: vehicle != null && canScan && !_saving ? _beginScan : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
