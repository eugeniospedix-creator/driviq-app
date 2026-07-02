import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../shell/dq_page.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DQ.cyanSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: DQ.cyan, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: DQ.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: DQ.textMuted, fontSize: 13, height: 1.35)),
                ],
              ),
            ),
            _DqSwitch(value: value, onChanged: enabled ? onChanged : null),
          ],
        ),
      ),
    );
  }
}

class _DqSwitch extends StatelessWidget {
  const _DqSwitch({required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final active = value && onChanged != null;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: active ? DQ.cyan.withValues(alpha: 0.25) : DQ.graphite3,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? DQ.cyan.withValues(alpha: 0.5) : DQ.line),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: active ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? DQ.cyan : DQ.textMuted,
              boxShadow: active
                  ? [BoxShadow(color: DQ.cyan.withValues(alpha: 0.5), blurRadius: 10)]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
