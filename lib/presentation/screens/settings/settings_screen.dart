import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/enums/settings_key.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/async/dq_async_view.dart';
import '../../widgets/cards/settings_tile.dart';
import '../../widgets/shell/dq_page.dart';
import '../../widgets/typography/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return DqPage(
      child: DqAsyncBody(
        asyncValue: settingsAsync,
        builder: (settings) => ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
          children: [
            const FadeSlideIn(
              child: SectionHeader(
                title: 'Settings',
                subtitle: 'Privacy, sensors and vehicle intelligence.',
              ),
            ),
            const SizedBox(height: 22),
            FadeSlideIn(
              delay: const Duration(milliseconds: 40),
              child: SettingsTile(
                icon: Icons.mic_rounded,
                title: 'Microphone',
                subtitle: 'Local audio analysis. Temporary files deleted after scan.',
                value: settings.microphoneEnabled,
                onChanged: (_) => ref.read(settingsProvider.notifier).toggle(SettingsKey.microphone),
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: SettingsTile(
                icon: Icons.screen_rotation_alt_rounded,
                title: 'Motion Sensors',
                subtitle: 'Accelerometer and gyroscope vibration profile.',
                value: settings.motionSensorsEnabled,
                onChanged: (_) => ref.read(settingsProvider.notifier).toggle(SettingsKey.motion),
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 120),
              child: SettingsTile(
                icon: Icons.shield_rounded,
                title: 'Privacy Mode',
                subtitle: 'Do not store raw cabin audio.',
                value: settings.privacyMode,
                onChanged: (_) => ref.read(settingsProvider.notifier).toggle(SettingsKey.privacy),
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: SettingsTile(
                icon: Icons.drive_eta_rounded,
                title: 'Safe Driving Mode',
                subtitle: 'Reduce interaction while the vehicle is moving.',
                value: settings.safeDrivingMode,
                onChanged: (_) => ref.read(settingsProvider.notifier).toggle(SettingsKey.safeDriving),
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: SettingsTile(
                icon: Icons.hub_rounded,
                title: 'Offline AI',
                subtitle: 'On-device diagnosis without cloud dependency.',
                value: settings.offlineAiEnabled,
                onChanged: (_) => ref.read(settingsProvider.notifier).toggle(SettingsKey.offlineAi),
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 240),
              child: SettingsTile(
                icon: Icons.cloud_rounded,
                title: 'Cloud AI',
                subtitle: 'Enhanced explanations via secure cloud inference.',
                value: settings.cloudAiEnabled,
                onChanged: (_) => ref.read(settingsProvider.notifier).toggle(SettingsKey.cloudAi),
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 280),
              child: SettingsTile(
                icon: Icons.bluetooth_drive_rounded,
                title: 'OBD-II',
                subtitle: 'Vehicle telemetry via diagnostic port.',
                value: settings.obdEnabled,
                enabled: false,
                onChanged: (_) {},
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 320),
              child: SettingsTile(
                icon: Icons.view_in_ar_rounded,
                title: 'AR Preview',
                subtitle: 'Augmented reality component inspection.',
                value: settings.arPreviewEnabled,
                enabled: false,
                onChanged: (_) {},
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 360),
              child: SettingsTile(
                icon: Icons.workspace_premium_rounded,
                title: 'Driviq Plus',
                subtitle: 'Advanced reports, export and fleet intelligence.',
                value: false,
                enabled: false,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
