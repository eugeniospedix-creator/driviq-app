import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/dq_tokens.dart';

class DqNavBar extends StatelessWidget {
  const DqNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home', route: AppRoutes.home),
    (icon: Icons.radar_rounded, label: 'Scan', route: AppRoutes.scan),
    (icon: Icons.garage_rounded, label: 'Garage', route: AppRoutes.garage),
    (icon: Icons.analytics_rounded, label: 'Report', route: AppRoutes.report),
    (icon: Icons.tune_rounded, label: 'Settings', route: AppRoutes.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: DQ.graphite3.withValues(alpha: 0.92),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final active = currentIndex == i;
                return Expanded(
                  child: _NavItem(
                    icon: item.icon,
                    label: item.label,
                    active: active,
                    onTap: () => context.go(item.route),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        height: 58,
        decoration: BoxDecoration(
          color: active ? DQ.graphite : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: active
              ? [BoxShadow(color: DQ.cyan.withValues(alpha: 0.12), blurRadius: 18)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: active ? DQ.cyan : DQ.textMuted),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                color: active ? DQ.textPrimary : DQ.textMuted,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
