import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/hive_local_store.dart';
import '../../data/datasources/local/local_data_seeder.dart';
import 'repository_providers.dart';

final bootstrapProvider = FutureProvider<void>((ref) async {
  final store = ref.watch(hiveStoreProvider);
  final seeder = LocalDataSeeder(
    store: store,
    vehicles: ref.watch(vehicleRepositoryProvider),
    diagnosis: ref.watch(diagnosisRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
  );
  await seeder.seedIfNeeded();
});

Future<HiveLocalStore> bootstrapHive() => HiveLocalStore.init();
