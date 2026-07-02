import 'package:flutter/material.dart';

import '../../core/visuals/fault_severity_colors.dart';
import '../../core/theme/dq_tokens.dart';
import '../../domain/catalog/vehicle_catalog.dart';
import '../../domain/entities/component_fault.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/enums/vehicle_view_mode.dart';
import 'interfaces/vehicle_renderer.dart';

/// Vector vehicle renderer — silhouette adapts per catalog entry until GLB assets ship.
class VectorVehicleRenderer implements VehicleRenderer {
  @override
  Widget build({
    required Vehicle vehicle,
    required VehicleViewMode viewMode,
    required bool scanning,
    required bool interactive,
    ComponentFault? highlightedFault,
    ValueChanged<ComponentFault>? onFaultSelected,
    List<ComponentFault> faults = const [],
    double animationPhase = 0,
  }) {
    final catalog = VehicleCatalog.byAssetKey(vehicle.modelAssetKey);
    final variant = catalog?.silhouetteVariant ?? 'sport_sedan';

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: size,
              painter: _VectorVehiclePainter(
                variant: variant,
                scanning: scanning,
                animationPhase: animationPhase,
                highlightedId: highlightedFault?.componentId,
                viewMode: viewMode,
              ),
            ),
            ...faults.map((fault) {
              final selected = highlightedFault?.id == fault.id;
              final color = FaultSeverityColors.accent(fault.severity);
              return Positioned(
                left: size.width * fault.anchor.x - (selected ? 19 : 15),
                top: size.height * fault.anchor.y - (selected ? 19 : 15),
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
            BoxShadow(
              color: color.withValues(alpha: 0.7),
              blurRadius: selected ? 28 : 14,
              spreadRadius: selected ? 2 : 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _VectorVehiclePainter extends CustomPainter {
  _VectorVehiclePainter({
    required this.variant,
    required this.scanning,
    required this.animationPhase,
    required this.viewMode,
    this.highlightedId,
  });

  final String variant;
  final bool scanning;
  final double animationPhase;
  final VehicleViewMode viewMode;
  final String? highlightedId;

  @override
  void paint(Canvas canvas, Size s) {
    final base = Colors.white;
    final cyan = DQ.cyan;
    final glow = Paint()
      ..color = cyan.withValues(alpha: scanning ? 0.22 : 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final line = Paint()
      ..color = base.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final thin = Paint()
      ..color = base.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final body = _bodyPath(s, variant);
    canvas.drawPath(body, glow);
    canvas.drawPath(body, line);

    if (viewMode == VehicleViewMode.interior || viewMode == VehicleViewMode.dashboard) {
      _paintInterior(canvas, s, line, thin);
    } else if (viewMode == VehicleViewMode.engine) {
      _paintEngine(canvas, s, line, cyan);
    } else {
      _paintExterior(canvas, s, line, thin, variant);
    }

    if (scanning) {
      final x = s.width * (0.08 + 0.84 * animationPhase);
      final beam = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            cyan.withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(x - 40, 0, 80, s.height))
        ..strokeWidth = 6;
      canvas.drawLine(Offset(x, s.height * 0.16), Offset(x, s.height * 0.84), beam);
    }
  }

  Path _bodyPath(Size s, String variant) {
    final low = variant.contains('suv');
    final roof = low ? 0.24 : 0.20;
    return Path()
      ..moveTo(s.width * 0.08, s.height * 0.62)
      ..cubicTo(s.width * 0.13, s.height * 0.42, s.width * 0.28, s.height * 0.36, s.width * 0.38, s.height * 0.34)
      ..cubicTo(s.width * 0.45, s.height * roof, s.width * 0.63, s.height * roof, s.width * 0.72, s.height * 0.33)
      ..cubicTo(s.width * 0.86, s.height * 0.37, s.width * 0.93, s.height * 0.51, s.width * 0.94, s.height * 0.63)
      ..lineTo(s.width * 0.83, s.height * 0.70)
      ..lineTo(s.width * 0.17, s.height * 0.70)
      ..close();
  }

  void _paintExterior(Canvas canvas, Size s, Paint line, Paint thin, String variant) {
    final cabin = Path()
      ..moveTo(s.width * 0.39, s.height * 0.35)
      ..lineTo(s.width * 0.50, s.height * 0.24)
      ..lineTo(s.width * 0.65, s.height * 0.25)
      ..lineTo(s.width * 0.75, s.height * 0.38);
    canvas.drawPath(cabin, line);

    if (variant == 'ev_sedan') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(s.width * 0.48, s.height * 0.30, s.width * 0.18, s.height * 0.04),
          const Radius.circular(4),
        ),
        line,
      );
    }

    for (final x in [0.27, 0.73]) {
      canvas.drawCircle(Offset(s.width * x, s.height * 0.70), 30, line);
      canvas.drawCircle(Offset(s.width * x, s.height * 0.70), 12, line);
      canvas.drawCircle(Offset(s.width * x, s.height * 0.70), 42, thin);
    }

    for (var i = 0; i < 12; i++) {
      final y = s.height * (0.30 + i * 0.035);
      canvas.drawLine(Offset(s.width * 0.13, y), Offset(s.width * 0.90, y), thin);
    }
  }

  void _paintInterior(Canvas canvas, Size s, Paint line, Paint thin) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.22, s.height * 0.38, s.width * 0.56, s.height * 0.22),
        const Radius.circular(18),
      ),
      line,
    );
    canvas.drawCircle(Offset(s.width * 0.32, s.height * 0.52), 18, line);
    for (var i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(s.width * 0.42, s.height * (0.40 + i * 0.03)),
        Offset(s.width * 0.72, s.height * (0.40 + i * 0.03)),
        thin,
      );
    }
  }

  void _paintEngine(Canvas canvas, Size s, Paint line, Color cyan) {
    final block = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.28, s.height * 0.38, s.width * 0.44, s.height * 0.18),
      const Radius.circular(10),
    );
    canvas.drawRRect(block, line);
    final accent = Paint()
      ..color = cyan.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(s.width * 0.32, s.height * (0.42 + i * 0.04)),
        Offset(s.width * 0.68, s.height * (0.42 + i * 0.04)),
        accent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VectorVehiclePainter old) =>
      old.animationPhase != animationPhase ||
      old.scanning != scanning ||
      old.highlightedId != highlightedId ||
      old.viewMode != viewMode;
}
