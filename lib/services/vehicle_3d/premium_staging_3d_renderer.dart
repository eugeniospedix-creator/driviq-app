import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/dq_tokens.dart';
import '../../core/visuals/fault_severity_colors.dart';
import '../../domain/entities/component_fault.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/vehicle_3d_metadata.dart';
import '../../domain/entities/vehicle_3d_view_state.dart';
import '../../domain/enums/vehicle_view_mode.dart';
import '../interfaces/vehicle_renderer.dart';

/// Premium staging renderer — perspective 3D twin until licensed GLB assets ship.
/// Clearly a digital preview, not a branded vehicle model.
class PremiumStaging3DRenderer implements VehicleRenderer {
  @override
  Widget build({
    required Vehicle vehicle,
    required VehicleViewMode viewMode,
    required Vehicle3DViewState viewState,
    required Vehicle3DMetadata metadata,
    required bool scanning,
    required bool interactive,
    ComponentFault? highlightedFault,
    ValueChanged<ComponentFault>? onFaultSelected,
    List<ComponentFault> faults = const [],
    double animationPhase = 0,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: size,
              painter: _Staging3DPainter(
                bodyType: metadata.bodyType,
                viewMode: viewMode,
                viewState: viewState,
                scanning: scanning,
                animationPhase: animationPhase,
                stagingLabel: metadata.stagingLabel ?? 'Digital Twin Preview',
              ),
            ),
            ...faults.map((fault) {
              final anchor = metadata.anchorFor(fault.componentId);
              final pos = anchor?.forView(viewMode);
              final projected = pos != null
                  ? _project(pos, viewState, size)
                  : Offset(fault.anchor.x * size.width, fault.anchor.y * size.height);
              final selected = highlightedFault?.id == fault.id;
              final color = FaultSeverityColors.accent(fault.severity);
              return Positioned(
                left: projected.dx - (selected ? 19 : 15),
                top: projected.dy - (selected ? 19 : 15),
                child: _Hotspot(
                  color: color,
                  selected: selected,
                  interactive: interactive,
                  onTap: () => onFaultSelected?.call(fault),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Offset _project(AnchorPosition3D pos, Vehicle3DViewState state, Size size) {
    final yaw = state.yaw * math.pi * 2;
    final x = pos.x - 0.5;
    final z = pos.z;
    final rotX = x * math.cos(yaw) + z * math.sin(yaw);
    final depth = 1 + rotX * 0.35;
    final screenX = 0.5 + rotX * state.zoom * 0.9;
    final screenY = pos.y - state.pitch * 0.22 + (1 - depth) * 0.04;
    return Offset(screenX * size.width, screenY * size.height);
  }
}

class _Hotspot extends StatelessWidget {
  const _Hotspot({
    required this.color,
    required this.selected,
    required this.interactive,
    this.onTap,
  });

  final Color color;
  final bool selected;
  final bool interactive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: interactive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: selected ? 38 : 30,
        height: selected ? 38 : 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: selected ? 28 : 14),
          ],
        ),
      ),
    );
  }
}

class _Staging3DPainter extends CustomPainter {
  _Staging3DPainter({
    required this.bodyType,
    required this.viewMode,
    required this.viewState,
    required this.scanning,
    required this.animationPhase,
    required this.stagingLabel,
  });

  final String bodyType;
  final VehicleViewMode viewMode;
  final Vehicle3DViewState viewState;
  final bool scanning;
  final double animationPhase;
  final String stagingLabel;

  @override
  void paint(Canvas canvas, Size s) {
    final center = Offset(s.width * 0.5, s.height * 0.54);
    final scale = viewState.zoom;

    _drawAmbientGlow(canvas, s, center, scale);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.rotate(viewState.yaw * 0.35);

    if (viewMode == VehicleViewMode.engine) {
      _paintEngine(canvas, s);
    } else if (viewMode == VehicleViewMode.interior || viewMode == VehicleViewMode.dashboard) {
      _paintInterior(canvas, s);
    } else if (viewMode == VehicleViewMode.suspension) {
      _paintSuspension(canvas, s);
    } else {
      _paintExterior(canvas, s, bodyType);
    }

    canvas.restore();

    if (scanning) {
      final x = s.width * (0.08 + 0.84 * animationPhase);
      final beam = Paint()
        ..shader = LinearGradient(
          colors: [Colors.transparent, DQ.cyan.withValues(alpha: 0.85), Colors.transparent],
        ).createShader(Rect.fromLTWH(x - 40, 0, 80, s.height))
        ..strokeWidth = 5;
      canvas.drawLine(Offset(x, s.height * 0.14), Offset(x, s.height * 0.86), beam);
    }

    _paintLabel(canvas, s);
  }

  void _drawAmbientGlow(Canvas canvas, Size s, Offset center, double scale) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          DQ.cyan.withValues(alpha: scanning ? 0.22 : 0.14),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: s.width * 0.42 * scale));
    canvas.drawCircle(center, s.width * 0.42 * scale, glow);
  }

  void _paintLabel(Canvas canvas, Size s) {
    final tp = TextPainter(
      text: TextSpan(
        text: stagingLabel.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.28),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((s.width - tp.width) / 2, s.height * 0.08));
  }

  void _paintExterior(Canvas canvas, Size s, String bodyType) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final thin = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final w = s.width * 0.38;
    final h = s.height * 0.22;
    final body = Path()
      ..moveTo(-w, h * 0.35)
      ..cubicTo(-w * 0.85, -h * 0.45, -w * 0.2, -h * 0.65, w * 0.05, -h * 0.7)
      ..cubicTo(w * 0.35, -h * 0.95, w * 0.75, -h * 0.55, w * 0.95, h * 0.1)
      ..lineTo(w * 0.75, h * 0.55)
      ..lineTo(-w * 0.75, h * 0.55)
      ..close();

    final glow = Paint()
      ..color = DQ.cyan.withValues(alpha: scanning ? 0.2 : 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawPath(body, glow);
    canvas.drawPath(body, line);

    if (bodyType == 'ev_sedan') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -h * 0.15), width: w * 0.5, height: h * 0.08), const Radius.circular(4)),
        line,
      );
    }

    for (final x in [-w * 0.55, w * 0.55]) {
      canvas.drawCircle(Offset(x, h * 0.55), 28, line);
      canvas.drawCircle(Offset(x, h * 0.55), 10, line);
      canvas.drawCircle(Offset(x, h * 0.55), 40, thin);
    }
  }

  void _paintEngine(Canvas canvas, Size s) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: s.width * 0.35, height: s.height * 0.14), const Radius.circular(10)),
      line,
    );
  }

  void _paintInterior(Canvas canvas, Size s) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: s.width * 0.42, height: s.height * 0.16), const Radius.circular(16)),
      line,
    );
    canvas.drawCircle(Offset(-s.width * 0.08, 0), 16, line);
  }

  void _paintSuspension(Canvas canvas, Size s) {
    final line = Paint()
      ..color = DQ.cyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final x in [-1.0, 1.0]) {
      canvas.drawLine(Offset(s.width * 0.12 * x, -s.height * 0.08), Offset(s.width * 0.08 * x, s.height * 0.12), line);
      canvas.drawCircle(Offset(s.width * 0.08 * x, s.height * 0.12), 14, line);
    }
  }

  @override
  bool shouldRepaint(covariant _Staging3DPainter old) =>
      old.viewState.yaw != viewState.yaw ||
      old.viewState.pitch != viewState.pitch ||
      old.viewState.zoom != viewState.zoom ||
      old.viewMode != viewMode ||
      old.scanning != scanning ||
      old.animationPhase != animationPhase;
}
