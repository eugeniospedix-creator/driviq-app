import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'garage_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

class DriviqShell extends StatefulWidget {
  const DriviqShell({super.key});
  @override State<DriviqShell> createState() => _DriviqShellState();
}

class _DriviqShellState extends State<DriviqShell> {
  int index = 0;
  final pages = const [HomeScreen(), ScanScreen(), GarageScreen(), ReportScreen(), SettingsScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
        body: pages[index],
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.92),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: DQ.line),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.10), blurRadius: 30, offset: const Offset(0, 14))],
          ),
          child: Row(children: [
            tab(0, Icons.home_rounded, 'Home'), tab(1, Icons.radar_rounded, 'Scan'), tab(2, Icons.garage_rounded, 'Garage'), tab(3, Icons.analytics_rounded, 'Report'), tab(4, Icons.tune_rounded, 'Settings')
          ]),
        ),
      );
  Widget tab(int i, IconData icon, String label) {
    final active = index == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => index = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 56,
          decoration: BoxDecoration(color: active ? DQ.graphite : Colors.transparent, borderRadius: BorderRadius.circular(22)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 21, color: active ? DQ.cyan : DQ.muted),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: active ? Colors.white : DQ.muted, fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}
