import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../application/providers/usecase_providers.dart';
import '../../../application/usecases/save_vehicle_profile_usecase.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/errors/app_exception.dart';
import '../../providers/vehicle_providers.dart';
import '../../widgets/buttons/dq_button.dart';
import '../../widgets/inputs/dq_text_field.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/vehicle/vehicle_photo_capture.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  static const _uuid = Uuid();

  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _km = TextEditingController();

  String? _vehicleId;
  String? _photoPath;
  DateTime? _createdAt;
  bool _saving = false;
  bool _addingAnother = false;

  @override
  void initState() {
    super.initState();
    _year.text = DateTime.now().year.toString();
  }

  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _km.dispose();
    super.dispose();
  }

  void _resetDraft() {
    _vehicleId = _uuid.v4();
    _photoPath = null;
    _createdAt = null;
    _make.clear();
    _model.clear();
    _year.text = DateTime.now().year.toString();
    _km.clear();
  }

  Future<void> _pickPhoto() async {
    final vehicleId = _vehicleId ??= _uuid.v4();
    final path = await pickAndSaveOriginalPhoto(
      context: context,
      ref: ref,
      vehicleId: vehicleId,
    );
    if (path != null && mounted) {
      setState(() {
        _vehicleId = vehicleId;
        _photoPath = path;
      });
    }
  }

  Future<void> _saveVehicle() async {
    final make = _make.text.trim();
    final model = _model.text.trim();
    if (make.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter make and model.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final year = int.tryParse(_year.text.trim());
    if (year == null || year < 1980 || year > DateTime.now().year + 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid year.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final mileage = int.tryParse(_km.text.trim());
      final saved = await ref.read(saveVehicleProfileUseCaseProvider).execute(
            SaveVehicleProfileInput(
              existingId: _vehicleId,
              make: make,
              model: model,
              year: year,
              mileageKm: mileage,
              isPrimary: true,
              createdAt: _createdAt,
              photoPath: _photoPath,
            ),
          );

      ref.invalidate(vehiclesProvider);
      ref.invalidate(primaryVehicleProvider);
      ref.invalidate(garageOverviewProvider);

      if (!mounted) return;
      setState(() {
        _addingAnother = false;
        _vehicleId = saved.id;
        _photoPath = saved.photoPath;
        _createdAt = saved.createdAt;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle saved.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _hasPhoto =>
      _photoPath != null && _photoPath!.isNotEmpty && File(_photoPath!).existsSync();

  @override
  Widget build(BuildContext context) {
    final primaryAsync = ref.watch(primaryVehicleProvider);

    return DqPage(
      child: primaryAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2, color: DQ.cyan),
          ),
        ),
        error: (_, _) => _buildSetupForm(),
        data: (primary) {
          if (primary != null && !_addingAnother) {
            return _SavedVehicleView(
              vehicle: primary,
              onAddAnother: () {
                setState(() {
                  _addingAnother = true;
                  _resetDraft();
                });
              },
            );
          }
          return _buildSetupForm();
        },
      ),
    );
  }

  Widget _buildSetupForm() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
      children: [
        _PhotoPickerTile(
          hasPhoto: _hasPhoto,
          photoPath: _photoPath,
          enabled: !_saving,
          onTap: _pickPhoto,
        ),
        const SizedBox(height: 22),
        DqTextField(controller: _make, label: 'Make', hint: 'e.g. BMW'),
        const SizedBox(height: 16),
        DqTextField(controller: _model, label: 'Model', hint: 'e.g. 320d'),
        const SizedBox(height: 16),
        DqTextField(
          controller: _year,
          label: 'Year',
          hint: '2024',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        DqTextField(
          controller: _km,
          label: 'Kilometres',
          hint: '48200',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 28),
        DqButton(
          label: _saving ? 'SAVING…' : 'SAVE VEHICLE',
          icon: Icons.check_rounded,
          enabled: !_saving,
          onTap: _saving ? null : _saveVehicle,
        ),
      ],
    );
  }
}

class _SavedVehicleView extends StatelessWidget {
  const _SavedVehicleView({
    required this.vehicle,
    required this.onAddAnother,
  });

  final Vehicle vehicle;
  final VoidCallback onAddAnother;

  bool get _hasPhoto =>
      vehicle.photoPath != null &&
      vehicle.photoPath!.isNotEmpty &&
      File(vehicle.photoPath!).existsSync();

  @override
  Widget build(BuildContext context) {
    final mileage = vehicle.mileageKm;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(DQ.radiusLg),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(DQ.radiusLg)),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: _hasPhoto
                      ? Image.file(
                          File(vehicle.photoPath!),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        )
                      : ColoredBox(
                          color: DQ.graphite3,
                          child: Icon(
                            Icons.directions_car_filled_rounded,
                            size: 56,
                            color: DQ.textMuted.withValues(alpha: 0.5),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.make} ${vehicle.model}',
                      style: const TextStyle(
                        color: DQ.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [
                        vehicle.year.toString(),
                        if (mileage != null) '${_formatKm(mileage)} km',
                      ].join(' · '),
                      style: const TextStyle(
                        color: DQ.textSecondary,
                        fontSize: 15,
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: onAddAnother,
            child: const Text(
              '+ Add another vehicle',
              style: TextStyle(
                color: DQ.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
                decorationThickness: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _formatKm(int km) {
    final text = km.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

class _PhotoPickerTile extends StatelessWidget {
  const _PhotoPickerTile({
    required this.hasPhoto,
    required this.photoPath,
    required this.enabled,
    required this.onTap,
  });

  final bool hasPhoto;
  final String? photoPath;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(DQ.radiusLg),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(DQ.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: hasPhoto
                      ? Image.file(
                          File(photoPath!),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        )
                      : ColoredBox(
                          color: DQ.graphite3,
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            color: DQ.cyan.withValues(alpha: 0.85),
                            size: 28,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Add your vehicle photo',
                  style: TextStyle(
                    color: DQ.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                    decorationThickness: 0,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: DQ.textMuted.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
