import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/shell.dart';

void main() => runApp(const DriviqApp());

class DriviqApp extends StatelessWidget {
  const DriviqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driviq',
      debugShowCheckedModeBanner: false,
      theme: DriviqTheme.light,
      home: const DriviqShell(),
    );
  }
}
