import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/component_status.dart';

class DigitalTwin extends StatefulWidget {
  final bool dark;
  final bool interactive;
  final bool scanning;
  final ValueChanged<ComponentStatus>? onSelect;
  final ComponentStatus? selected;
  const DigitalTwin({super.key, this.dark = false, this.interactive = true, this.scanning = false, this.onSelect, this.selected});

  @override
  State<DigitalTwin> createState() => _DigitalTwinState();
}

class _DigitalTwinState extends State<DigitalTwin> with SingleTickerProviderStateMixin {
  late final AnimationController ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  @override void dispose(){ctrl.dispose(); super.dispose();}

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) => LayoutBuilder(builder: (context, box) {
          final size = Size(box.maxWidth, box.maxHeight);
          return Stack(
            children: [
              CustomPaint(size: size, painter: TwinPainter(widget.dark, widget.scanning, ctrl.value, widget.selected?.id)),
              ...demoComponents.map((c) => Positioned(
                    left: size.width * c.anchor.dx - 16,
                    top: size.height * c.anchor.dy - 16,
                    child: GestureDetector(
                      onTap: widget.interactive ? () => widget.onSelect?.call(c) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: widget.selected?.id == c.id ? 38 : 30,
                        width: widget.selected?.id == c.id ? 38 : 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.color,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: c.color.withOpacity(.65), blurRadius: widget.selected?.id == c.id ? 28 : 16)],
                        ),
                      ),
                    ),
                  )),
            ],
          );
        }),
      );
}

class TwinPainter extends CustomPainter {
  final bool dark, scanning;
  final double t;
  final String? selectedId;
  TwinPainter(this.dark, this.scanning, this.t, this.selectedId);

  @override
  void paint(Canvas canvas, Size s) {
    final base = dark ? Colors.white : DQ.graphite;
    final cyan = DQ.cyan;
    final glow = Paint()..color = cyan.withOpacity(scanning ? .18 : .09)..style = PaintingStyle.stroke..strokeWidth = 18..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    final line = Paint()..color = base.withOpacity(dark ? .75 : .65)..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round;
    final thin = Paint()..color = base.withOpacity(dark ? .16 : .10)..style = PaintingStyle.stroke..strokeWidth = 1;

    final body = Path()
      ..moveTo(s.width*.08, s.height*.62)
      ..cubicTo(s.width*.13, s.height*.42, s.width*.28, s.height*.36, s.width*.38, s.height*.34)
      ..cubicTo(s.width*.45, s.height*.20, s.width*.63, s.height*.20, s.width*.72, s.height*.33)
      ..cubicTo(s.width*.86, s.height*.37, s.width*.93, s.height*.51, s.width*.94, s.height*.63)
      ..lineTo(s.width*.83, s.height*.70)
      ..lineTo(s.width*.17, s.height*.70)
      ..close();
    canvas.drawPath(body, glow);
    canvas.drawPath(body, line);

    final cabin = Path()
      ..moveTo(s.width*.39, s.height*.35)
      ..lineTo(s.width*.50, s.height*.24)
      ..lineTo(s.width*.65, s.height*.25)
      ..lineTo(s.width*.75, s.height*.38);
    canvas.drawPath(cabin, line);

    for (final x in [.27, .73]) {
      canvas.drawCircle(Offset(s.width*x, s.height*.70), 30, line);
      canvas.drawCircle(Offset(s.width*x, s.height*.70), 12, line);
      canvas.drawCircle(Offset(s.width*x, s.height*.70), 42, thin);
    }

    for (int i=0;i<12;i++) {
      final y=s.height*(.30+i*.035);
      canvas.drawLine(Offset(s.width*.13,y),Offset(s.width*.90,y), thin);
    }
    if (scanning) {
      final x = s.width * (.08 + .86 * t);
      final p = Paint()..shader = const LinearGradient(colors:[Colors.transparent,DQ.cyan,Colors.transparent]).createShader(Rect.fromLTWH(x-30,0,60,s.height))..strokeWidth=5;
      canvas.drawLine(Offset(x, s.height*.18), Offset(x, s.height*.82), p);
    }
  }

  @override bool shouldRepaint(covariant TwinPainter oldDelegate) => true;
}
