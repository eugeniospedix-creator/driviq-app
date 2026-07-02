import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'presentation/providers/bootstrap_provider.dart';
import 'presentation/providers/repository_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await bootstrapHive();

  runApp(
    ProviderScope(
      overrides: [hiveStoreProvider.overrideWithValue(store)],
      child: const DriviqApp(),
    ),
  );
}
