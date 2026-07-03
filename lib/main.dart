import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'presentation/providers/bootstrap_provider.dart';
import 'presentation/providers/repository_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  final store = await bootstrapHive();

  runApp(
    ProviderScope(
      overrides: [hiveStoreProvider.overrideWithValue(store)],
      child: const DriviqApp(),
    ),
  );
}
