import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/vehicle.dart';
import '../../providers/repository_providers.dart';
import '../../providers/vehicle_photo_providers.dart';
import '../../providers/vehicle_providers.dart';

enum VehiclePhotoCaptureSource { camera, gallery }

/// Pick + save original image for a vehicle id (works before the vehicle is saved).
Future<String?> pickAndSaveOriginalPhoto({
  required BuildContext context,
  required WidgetRef ref,
  required String vehicleId,
}) async {
  final source = await showVehiclePhotoSourceSheet(context);
  if (source == null || !context.mounted) return null;

  final picked = await ImagePicker().pickImage(
    source: source == VehiclePhotoCaptureSource.camera
        ? ImageSource.camera
        : ImageSource.gallery,
    imageQuality: 100,
  );
  if (picked == null || !context.mounted) return null;

  final photos = ref.read(vehiclePhotoRepositoryProvider);
  return photos.saveOriginalFromPath(
    vehicleId: vehicleId,
    sourcePath: picked.path,
  );
}

/// Updates photo on an already-saved vehicle.
Future<Vehicle?> captureVehiclePhotoFlow({
  required BuildContext context,
  required WidgetRef ref,
  required Vehicle vehicle,
}) async {
  final path = await pickAndSaveOriginalPhoto(
    context: context,
    ref: ref,
    vehicleId: vehicle.id,
  );
  if (path == null) return null;

  final repo = ref.read(vehicleRepositoryProvider);
  final existing = await repo.getById(vehicle.id);
  if (existing == null) return null;

  final photos = ref.read(vehiclePhotoRepositoryProvider);
  await photos.deleteIfExists(existing.photoPath);

  final updated = existing.copyWith(photoPath: path, updatedAt: DateTime.now());
  await repo.save(updated);

  ref.invalidate(vehiclesProvider);
  ref.invalidate(primaryVehicleProvider);
  ref.invalidate(garageOverviewProvider);
  return updated;
}

Future<VehiclePhotoCaptureSource?> showVehiclePhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<VehiclePhotoCaptureSource>(
    context: context,
    backgroundColor: DQ.graphite2,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(DQ.radiusXl)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Vehicle photo',
              style: TextStyle(
                color: DQ.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
                decorationThickness: 0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your original image is imported exactly as selected.',
              style: TextStyle(
                color: DQ.textSecondary,
                fontSize: 14,
                height: 1.4,
                decoration: TextDecoration.none,
                decorationThickness: 0,
              ),
            ),
            const SizedBox(height: 20),
            _SourceTile(
              icon: Icons.photo_camera_rounded,
              label: 'Take photo',
              onTap: () => Navigator.pop(context, VehiclePhotoCaptureSource.camera),
            ),
            const SizedBox(height: 10),
            _SourceTile(
              icon: Icons.photo_library_rounded,
              label: 'Choose from gallery',
              onTap: () => Navigator.pop(context, VehiclePhotoCaptureSource.gallery),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: DQ.textMuted, decoration: TextDecoration.none),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(DQ.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DQ.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DQ.cyanSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: DQ.cyan),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
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
