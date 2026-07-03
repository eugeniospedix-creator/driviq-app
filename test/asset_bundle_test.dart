import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driviq/core/constants/vehicle_artwork_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all Kenney hero assets are bundled', () async {
    for (final path in VehicleArtworkPaths.allHeroes) {
      await expectLater(rootBundle.load(path), completes);
    }
  });

  test('all Kenney GLB models are bundled', () async {
    for (final path in VehicleArtworkPaths.allModels) {
      await expectLater(rootBundle.load(path), completes);
    }
  });

  test('brand logo asset is bundled', () async {
    await expectLater(
      rootBundle.load('assets/brand/driviq_app_icon.png'),
      completes,
    );
  });
}
