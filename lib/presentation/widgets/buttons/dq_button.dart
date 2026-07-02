import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';

class DqButton extends StatefulWidget {
  const DqButton({
    super.key,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.variant = DqButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final DqButtonVariant variant;
  final IconData? icon;

  @override
  State<DqButton> createState() => _DqButtonState();
}

enum DqButtonVariant { primary, secondary, ghost }

class _DqButtonState extends State<DqButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onTap != null;
    final bg = switch (widget.variant) {
      DqButtonVariant.primary => enabled ? DQ.cyan : DQ.graphite3,
      DqButtonVariant.secondary => DQ.graphite3,
      DqButtonVariant.ghost => Colors.transparent,
    };
    final fg = switch (widget.variant) {
      DqButtonVariant.primary => enabled ? DQ.graphite : DQ.textMuted,
      _ => enabled ? DQ.textPrimary : DQ.textMuted,
    };

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 58,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(DQ.radiusMd),
            border: widget.variant == DqButtonVariant.ghost
                ? Border.all(color: DQ.line)
                : null,
            boxShadow: widget.variant == DqButtonVariant.primary && enabled
                ? [BoxShadow(color: DQ.cyan.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: fg, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
