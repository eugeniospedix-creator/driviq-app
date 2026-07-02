import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/hive_boxes.dart';

class HiveLocalStore {
  HiveLocalStore._({
    required this.meta,
    required this.vehicles,
    required this.scans,
    required this.settings,
  });

  final Box<dynamic> meta;
  final Box<dynamic> vehicles;
  final Box<dynamic> scans;
  final Box<dynamic> settings;

  static Future<HiveLocalStore> init() async {
    await Hive.initFlutter();
    final meta = await Hive.openBox(HiveBoxes.meta);
    final vehicles = await Hive.openBox(HiveBoxes.vehicles);
    final scans = await Hive.openBox(HiveBoxes.scans);
    final settings = await Hive.openBox(HiveBoxes.settings);
    return HiveLocalStore._(
      meta: meta,
      vehicles: vehicles,
      scans: scans,
      settings: settings,
    );
  }

  int get seedVersion => meta.get('seedVersion', defaultValue: 0) as int;

  Future<void> setSeedVersion(int version) => meta.put('seedVersion', version);
}
