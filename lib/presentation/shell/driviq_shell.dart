import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/shell/dq_nav_bar.dart';

class DriviqShell extends StatelessWidget {
  const DriviqShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  int get _index => switch (shell.currentIndex) {
        0 => 0,
        1 => 1,
        2 => 2,
        3 => 3,
        4 => 4,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: shell,
      bottomNavigationBar: DqNavBar(currentIndex: _index),
    );
  }
}
