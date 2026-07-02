import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class DQPage extends StatelessWidget {
  final Widget child;
  const DQPage({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), DQ.snow, DQ.ice],
          ),
        ),
        child: SafeArea(child: child),
      );
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  const GlassPanel({super.key, required this.child, this.padding = const EdgeInsets.all(22), this.color});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? Colors.white.withOpacity(.78),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: Colors.white.withOpacity(.72)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 30, offset: const Offset(0, 16))],
            ),
            child: child,
          ),
        ),
      );
}

class DarkPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const DarkPanel({super.key, required this.child, this.padding = const EdgeInsets.all(22)});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: DQ.graphite,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: Colors.white.withOpacity(.08)),
          boxShadow: [BoxShadow(color: DQ.cyan.withOpacity(.14), blurRadius: 44, offset: const Offset(0, 20))],
        ),
        child: child,
      );
}

class DQButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool dark;
  const DQButton({super.key, required this.label, this.onTap, this.dark = true});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 62,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: dark ? DQ.graphite : Colors.white,
            foregroundColor: dark ? Colors.white : DQ.graphite,
            disabledBackgroundColor: Colors.black12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: .6)),
        ),
      );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const SectionHeader({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      );
}
