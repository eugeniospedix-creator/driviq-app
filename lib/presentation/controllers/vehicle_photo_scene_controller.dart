import 'package:flutter/material.dart';

/// Reserved for future real 3D mesh scenes. 2D photos use [InteractiveViewer] directly.
class VehiclePhotoSceneController extends ChangeNotifier {
  VehiclePhotoSceneController({this.enableInteraction = false});

  final bool enableInteraction;

  void reset() {
    notifyListeners();
  }
}
