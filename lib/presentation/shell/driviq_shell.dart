import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/shell/dq_nav_bar.dart';

class DriviqShell extends StatelessWidget {
  const DriviqShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: shell,
      bottomNavigationBar: DqNavBar(currentIndex: shell.currentIndex),
    );
  }
}
