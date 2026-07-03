import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import 'home_vehicle_body_type.dart';
import 'home_vehicle_silhouette_geometry.dart';

/// Premium side-profile studio renderer — logo-inspired silhouette, realistic proportions.
class HomeVehicleStudioPainter extends CustomPainter {
  HomeVehicleStudioPainter({
    required this.bodyType,
    required this.accent,
    required this.phase,
  });

  final HomeVehicleBodyType bodyType;
  final Color accent;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = HomeVehicleSilhouetteGeometry.bounds(size);
    final floatY = math.sin(phase * math.pi * 2) * 1.2;

    canvas.save();
    canvas.translate(0, floatY);

    _paintStudioFloor(canvas, size, bounds);
    _paintGroundShadow(canvas, bounds);
    _paintWheels(canvas, bounds, rear: true);
    _paintBody(canvas, bounds);
    _paintRockerDetail(canvas, bounds);
    _paintWheels(canvas, bounds, rear: false);
    _paintGlass(canvas, bounds);
    _paintBodyHighlights(canvas, bounds);
    _paintHeadlights(canvas, bounds);
    _paintRimLight(canvas, bounds);

    canvas.restore();
  }

  void _paintStudioFloor(Canvas canvas, Size size, Rect bounds) {
    final floorY = bounds.bottom + bounds.height * 0.12;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bounds.center.dx, floorY),
        width: bounds.width * 0.82,
        height: bounds.height * 0.18,
      ),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(bounds.center.dx, floorY),
          bounds.width * 0.42,
          [
            accent.withValues(alpha: 0.08),
            DQ.voidBlack.withValues(alpha: 0.0),
          ],
        ),
    );
  }

  void _paintGroundShadow(Canvas canvas, Rect bounds) {
    final shadowRect = Rect.fromCenter(
      center: Offset(bounds.center.dx, bounds.bottom + bounds.height * 0.06),
      width: bounds.width * 0.78,
      height: bounds.height * 0.12,
    );
    canvas.drawOval(
      shadowRect,
      Paint()
        ..shader = ui.Gradient.radial(
          shadowRect.center,
          shadowRect.width * 0.5,
          [
            Colors.black.withValues(alpha: 0.70),
            Colors.black.withValues(alpha: 0.20),
            Colors.transparent,
          ],
          [0.0, 0.6, 1.0],
        ),
    );
  }

  void _paintBody(Canvas canvas, Rect bounds) {
    final body = HomeVehicleSilhouetteGeometry.bodyPath(bodyType, bounds);

    canvas.drawPath(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(bounds.left, bounds.top + bounds.height * 0.2),
          Offset(bounds.right, bounds.bottom),
          const [
            Color(0xFF3A4858),
            Color(0xFF1A2430),
            Color(0xFF0C1218),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    final sheen = Paint()
      ..shader = ui.Gradient.linear(
        Offset(bounds.left + bounds.width * 0.55, bounds.top),
        Offset(bounds.right, bounds.top + bounds.height * 0.55),
        [
          Colors.white.withValues(alpha: 0.20),
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        [0.0, 0.35, 1.0],
      )
      ..blendMode = BlendMode.plus;
    canvas.drawPath(body, sheen);

    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.07),
    );
  }

  void _paintRockerDetail(Canvas canvas, Rect bounds) {
    final rocker = HomeVehicleSilhouetteGeometry.rockerPath(bodyType, bounds);
    canvas.drawPath(
      rocker,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF0A1018).withValues(alpha: 0.85),
    );
  }

  void _paintGlass(Canvas canvas, Rect bounds) {
    final glass = HomeVehicleSilhouetteGeometry.glassPath(bodyType, bounds);

    canvas.drawPath(
      glass,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(bounds.left + bounds.width * 0.35, bounds.top),
          Offset(bounds.left + bounds.width * 0.75, bounds.top + bounds.height * 0.5),
          [
            const Color(0xFF2A4A68).withValues(alpha: 0.90),
            const Color(0xFF0C1824).withValues(alpha: 0.96),
          ],
        ),
    );

    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.14),
    );

    final pillar = Paint()
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.08);
    final aPillar = Offset(bounds.left + bounds.width * 0.76, bounds.top + bounds.height * 0.48);
    final bPillar = Offset(bounds.left + bounds.width * 0.22, bounds.top + bounds.height * 0.48);
    canvas.drawLine(aPillar, Offset(aPillar.dx, aPillar.dy - bounds.height * 0.18), pillar);
    canvas.drawLine(bPillar, Offset(bPillar.dx, bPillar.dy - bounds.height * 0.14), pillar);
  }

  void _paintWheels(Canvas canvas, Rect bounds, {required bool rear}) {
    final wheels = HomeVehicleSilhouetteGeometry.wheels(bodyType, bounds);
    final index = rear ? 1 : 0;
    final wheel = wheels[index];
    final r = wheel.radiusX;

    canvas.drawCircle(wheel.center, r * 1.08, Paint()..color = const Color(0xFF060A0E));

    canvas.drawCircle(
      wheel.center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          wheel.center + Offset(-r * 0.15, -r * 0.15),
          r,
          const [Color(0xFF4A5664), Color(0xFF1E2832), Color(0xFF0A1018)],
        ),
    );

    canvas.drawCircle(
      wheel.center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = accent.withValues(alpha: 0.40),
    );

    canvas.drawCircle(wheel.center, r * 0.55, Paint()..color = const Color(0xFF2A3542));
    canvas.drawCircle(wheel.center, r * 0.18, Paint()..color = const Color(0xFF0A1018));

    for (var i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi * 2;
      final end = wheel.center + Offset(math.cos(angle) * r * 0.72, math.sin(angle) * r * 0.72);
      canvas.drawLine(
        wheel.center,
        end,
        Paint()
          ..strokeWidth = r * 0.09
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF5A6878).withValues(alpha: 0.9),
      );
    }
  }

  void _paintBodyHighlights(Canvas canvas, Rect bounds) {
    final hood = Path()
      ..moveTo(bounds.left + bounds.width * 0.82, bounds.top + bounds.height * 0.48)
      ..quadraticBezierTo(
        bounds.left + bounds.width * 0.92,
        bounds.top + bounds.height * 0.32,
        bounds.left + bounds.width * 0.88,
        bounds.top + bounds.height * 0.42,
      );
    canvas.drawPath(
      hood,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = ui.Gradient.linear(
          Offset(bounds.left + bounds.width * 0.82, bounds.top + bounds.height * 0.35),
          Offset(bounds.right, bounds.top + bounds.height * 0.48),
          [Colors.white.withValues(alpha: 0.22), Colors.transparent],
        ),
    );
  }

  void _paintHeadlights(Canvas canvas, Rect bounds) {
    final front = Offset(bounds.right - bounds.width * 0.04, bounds.top + bounds.height * 0.52);
    canvas.drawOval(
      Rect.fromCenter(center: front, width: bounds.width * 0.035, height: bounds.height * 0.10),
      Paint()..color = Colors.white.withValues(alpha: bodyType == HomeVehicleBodyType.evSedan ? 0.45 : 0.32),
    );
    canvas.drawOval(
      Rect.fromCenter(center: front, width: bounds.width * 0.06, height: bounds.height * 0.16),
      Paint()
        ..shader = ui.Gradient.radial(
          front,
          bounds.width * 0.04,
          [Colors.white.withValues(alpha: 0.20), Colors.transparent],
        )
        ..blendMode = BlendMode.plus,
    );
  }

  void _paintRimLight(Canvas canvas, Rect bounds) {
    final roof = Path()
      ..moveTo(bounds.left + bounds.width * 0.14, bounds.top + bounds.height * 0.50)
      ..cubicTo(
        bounds.left + bounds.width * 0.35,
        bounds.top + bounds.height * 0.18,
        bounds.left + bounds.width * 0.62,
        bounds.top + bounds.height * 0.14,
        bounds.left + bounds.width * 0.84,
        bounds.top + bounds.height * 0.48,
      );

    canvas.drawPath(
      roof,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..shader = ui.Gradient.linear(
          Offset(bounds.left, bounds.top),
          Offset(bounds.right, bounds.top),
          [
            accent.withValues(alpha: 0.05),
            accent.withValues(alpha: 0.55),
            accent.withValues(alpha: 0.15),
          ],
        )
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(covariant HomeVehicleStudioPainter oldDelegate) {
    return oldDelegate.bodyType != bodyType ||
        oldDelegate.accent != accent ||
        (oldDelegate.phase - phase).abs() > 0.001;
  }
}
