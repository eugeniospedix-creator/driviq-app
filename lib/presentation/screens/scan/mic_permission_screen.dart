import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/buttons/dq_button.dart';
import '../../widgets/shell/dq_page.dart';

class MicPermissionScreen extends ConsumerWidget {
  const MicPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DqPage(
      child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DQ.cyanSoft,
                  boxShadow: [BoxShadow(color: DQ.cyan.withValues(alpha: 0.25), blurRadius: 32)],
                ),
                child: const Icon(Icons.mic_rounded, color: DQ.cyan, size: 40),
              ),
              const SizedBox(height: 28),
              const Text(
                'Acoustic Intelligence',
                textAlign: TextAlign.center,
                style: TextStyle(color: DQ.textPrimary, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.6),
              ),
              const SizedBox(height: 12),
              const Text(
                'Driviq analyzes engine harmonics and vibration through your microphone. Audio is processed on-device and never stored when Privacy Mode is on.',
                textAlign: TextAlign.center,
                style: TextStyle(color: DQ.textSecondary, fontSize: 15, height: 1.45),
              ),
              const Spacer(),
              DqButton(
                label: 'ENABLE MICROPHONE',
                icon: Icons.mic_external_on_rounded,
                onTap: () async {
                  final service = ref.read(microphonePermissionServiceProvider);
                  final granted = await service.request();
                  ref.invalidate(microphonePermissionProvider);
                  if (!context.mounted) return;
                  if (granted) {
                    context.pushReplacement(AppRoutes.scanRunning);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Microphone access is required for acoustic scan.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              DqButton(
                label: 'NOT NOW',
                variant: DqButtonVariant.ghost,
                onTap: () => context.pop(),
              ),
              const SizedBox(height: 24),
            ],
        ),
      ),
    );
  }
}
