import 'package:permission_handler/permission_handler.dart';

/// Microphone permission gateway for the diagnostic pipeline.
class MicrophonePermissionService {
  Future<bool> get isGranted async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  Future<bool> request() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> openSettings() async => openAppSettings();
}
