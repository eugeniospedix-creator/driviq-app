import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/enums/vehicle_view_mode.dart';

class ViewModeSelector extends StatelessWidget {
  const ViewModeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final VehicleViewMode selected;
  final ValueChanged<VehicleViewMode> onSelected;

  static const _modes = [
    VehicleViewMode.exterior,
    VehicleViewMode.engine,
    VehicleViewMode.interior,
    VehicleViewMode.suspension,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _modes.map((mode) {
          final active = mode == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? DQ.cyan.withValues(alpha: 0.18) : DQ.graphite3,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: active ? DQ.cyan.withValues(alpha: 0.5) : DQ.line),
                ),
                child: Text(
                  mode.label.toUpperCase(),
                  style: TextStyle(
                    color: active ? DQ.cyan : DQ.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
