import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';

class DqTextField extends StatelessWidget {
  const DqTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: DQ.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: DQ.graphite3,
            borderRadius: BorderRadius.circular(DQ.radiusMd),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(color: DQ.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            cursorColor: DQ.cyan,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: DQ.textMuted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
