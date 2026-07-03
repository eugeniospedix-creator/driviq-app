import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/enums/vehicle_model_generation_status.dart';
import '../../../domain/enums/vehicle_photo_angle.dart';
import '../../providers/vehicle_model_providers.dart';
import '../../widgets/buttons/dq_button.dart';

class CreateVehicle3DScreen extends ConsumerStatefulWidget {
  const CreateVehicle3DScreen({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  ConsumerState<CreateVehicle3DScreen> createState() => _CreateVehicle3DScreenState();
}

class _CreateVehicle3DScreenState extends ConsumerState<CreateVehicle3DScreen> {
  var _capturing = false;
  var _step = 0;
  var _busy = false;

  VehiclePhotoAngle get _angle => VehiclePhotoAngle.captureSequence[_step];

  Future<void> _capture() async {
    setState(() => _busy = true);
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 92);
      if (picked == null) return;
      final generator = ref.read(productionVehicleModelGeneratorProvider);
      await generator.saveAnglePhoto(
        vehicleId: widget.vehicle.id,
        angle: _angle,
        localPath: picked.path,
      );
      ref.invalidate(vehiclePhotoSetProvider(widget.vehicle.id));
      if (_step < VehiclePhotoAngle.captureSequence.length - 1) {
        setState(() => _step++);
      } else {
        await generator.submitForReconstruction(widget.vehicle.id);
        ref.invalidate(vehicleModelAssetProvider(widget.vehicle.id));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _handleBack() {
    if (_capturing) {
      setState(() => _capturing = false);
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DQ.voidBlack,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: DQ.textPrimary),
          onPressed: _handleBack,
        ),
        title: Text(
          _capturing ? 'Capture photos' : 'Create your 3D vehicle',
          style: const TextStyle(
            color: DQ.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
            decorationThickness: 0,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _capturing ? _buildCapturePhase() : _buildIntroPhase(),
      ),
    );
  }

  Widget _buildIntroPhase() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
      children: [
        const Text(
          'Create your 3D vehicle',
          style: TextStyle(
            color: DQ.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.2,
            decoration: TextDecoration.none,
            decorationThickness: 0,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Take photos around your vehicle following the guide.',
          style: TextStyle(
            color: DQ.textSecondary,
            fontSize: 15,
            height: 1.45,
            decoration: TextDecoration.none,
            decorationThickness: 0,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Instructions',
          style: TextStyle(
            color: DQ.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
            decorationThickness: 0,
          ),
        ),
        const SizedBox(height: 14),
        const _InstructionLine('Good lighting'),
        const _InstructionLine('Entire vehicle visible'),
        const _InstructionLine('Walk around the vehicle'),
        const _InstructionLine('Avoid reflections'),
        const _InstructionLine('Take between 12 and 20 photos'),
        const SizedBox(height: 36),
        DqButton(
          label: 'START CAPTURE',
          icon: Icons.camera_alt_rounded,
          onTap: () => setState(() {
            _capturing = true;
            _step = 0;
          }),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Back',
              style: TextStyle(
                color: DQ.textMuted,
                fontSize: 15,
                decoration: TextDecoration.none,
                decorationThickness: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapturePhase() {
    final photoSet = ref.watch(vehiclePhotoSetProvider(widget.vehicle.id));
    final asset = ref.watch(vehicleModelAssetProvider(widget.vehicle.id));
    final captured = photoSet.asData?.value?.capturedCount ?? 0;
    final total = VehiclePhotoAngle.captureSequence.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
      children: [
        Text(
          'Step ${_step + 1} of $total',
          style: const TextStyle(
            color: DQ.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
            decorationThickness: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _angle.title,
          style: const TextStyle(
            color: DQ.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
            decorationThickness: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _angle.guide,
          style: const TextStyle(
            color: DQ.textSecondary,
            fontSize: 14,
            height: 1.45,
            decoration: TextDecoration.none,
            decorationThickness: 0,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(DQ.radiusMd),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Text(
            'Captured $captured / $total',
            style: const TextStyle(
              color: DQ.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
              decorationThickness: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        asset.when(
          data: (model) {
            if (model.status == VehicleModelGenerationStatus.notStarted) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(DQ.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.status.label,
                    style: const TextStyle(
                      color: DQ.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                      decorationThickness: 0,
                    ),
                  ),
                  if (model.statusMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      model.statusMessage!,
                      style: const TextStyle(
                        color: DQ.textMuted,
                        fontSize: 13,
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
                      ),
                    ),
                  ],
                  if (model.status == VehicleModelGenerationStatus.processing ||
                      model.status == VehicleModelGenerationStatus.pendingService) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: model.progress > 0 ? model.progress : null,
                      color: DQ.cyan,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 28),
        DqButton(
          label: _busy ? 'CAPTURING…' : 'CAPTURE PHOTO',
          icon: Icons.camera_alt_rounded,
          enabled: !_busy,
          onTap: _busy ? null : _capture,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _busy ? null : () => setState(() => _capturing = false),
            child: const Text(
              'Back',
              style: TextStyle(
                color: DQ.textMuted,
                fontSize: 15,
                decoration: TextDecoration.none,
                decorationThickness: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InstructionLine extends StatelessWidget {
  const _InstructionLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: DQ.cyan,
              fontSize: 15,
              height: 1.45,
              decoration: TextDecoration.none,
              decorationThickness: 0,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: DQ.textSecondary,
                fontSize: 15,
                height: 1.45,
                decoration: TextDecoration.none,
                decorationThickness: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
