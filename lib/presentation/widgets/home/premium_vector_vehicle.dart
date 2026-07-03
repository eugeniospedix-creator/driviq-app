import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/catalog/vehicle_catalog.dart';
import '../../../domain/catalog/vehicle_body_resolver.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/enums/driviq_weather_mood.dart';
import '../../../domain/enums/vehicle_body_archetype.dart';

enum PremiumVehicleShape { hatchback, sedan, suv, sport }

PremiumVehicleShape premiumVehicleShapeFor(Vehicle vehicle) {
  final catalog = VehicleCatalog.byAssetKey(vehicle.modelAssetKey);
  if (catalog?.silhouetteVariant == 'sport_sedan') {
    return PremiumVehicleShape.sport;
  }

  final key = '${vehicle.make} ${vehicle.model}'.toLowerCase();
  if (key.contains('m3') || key.contains('coupe') || key.contains('sport')) {
    return PremiumVehicleShape.sport;
  }

  return switch (VehicleBodyResolver.resolve(vehicle)) {
    VehicleBodyArchetype.suv => PremiumVehicleShape.suv,
    VehicleBodyArchetype.hatchback => PremiumVehicleShape.hatchback,
    VehicleBodyArchetype.sedan => PremiumVehicleShape.sedan,
  };
}

/// Premium vector vehicle — always visible, GPU-friendly, weather-reactive.
class PremiumVectorVehicle extends StatelessWidget {
  const PremiumVectorVehicle({
    super.key,
    required this.vehicle,
    required this.mood,
    this.accent = const Color(0xFF19D6FF),
    this.progress = 0,
  });

  final Vehicle vehicle;
  final DriviqWeatherMood mood;
  final Color accent;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: PremiumVectorVehiclePainter(
          shape: premiumVehicleShapeFor(vehicle),
          mood: mood,
          accent: accent,
          progress: progress,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class PremiumVectorVehiclePainter extends CustomPainter {
  const PremiumVectorVehiclePainter({
    required this.shape,
    required this.mood,
    required this.accent,
    required this.progress,
  });

  final PremiumVehicleShape shape;
  final DriviqWeatherMood mood;
  final Color accent;
  final double progress;

  bool get _headlightsOn =>
      mood == DriviqWeatherMood.clearNight ||
      mood == DriviqWeatherMood.rain ||
      mood == DriviqWeatherMood.storm ||
      mood == DriviqWeatherMood.fog ||
      mood == DriviqWeatherMood.snow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final carW = w * 0.86;
    final carH = h * 0.48;
    final left = (w - carW) / 2;
    final top = h * 0.27 + math.sin(progress * math.pi * 2) * 1.2;
    final rect = Rect.fromLTWH(left, top, carW, carH);

    _paintFloor(canvas, size, rect);
    _paintBody(canvas, rect);
    _paintGlass(canvas, rect);
    _paintDetails(canvas, rect);
    _paintWheels(canvas, rect);
    _paintWeatherOnCar(canvas, rect);
  }

  Color get _bodyTop => switch (mood) {
        DriviqWeatherMood.clearDay => const Color(0xFF9BA8B7),
        DriviqWeatherMood.snow => const Color(0xFFC4CED8),
        DriviqWeatherMood.clearNight => const Color(0xFF55606F),
        DriviqWeatherMood.rain || DriviqWeatherMood.storm => const Color(0xFF6F7B8A),
        _ => const Color(0xFF8995A4),
      };

  Color get _bodyBottom => switch (mood) {
        DriviqWeatherMood.clearDay => const Color(0xFF2D3747),
        DriviqWeatherMood.snow => const Color(0xFF667282),
        DriviqWeatherMood.clearNight => const Color(0xFF161F2D),
        DriviqWeatherMood.rain || DriviqWeatherMood.storm => const Color(0xFF202B3A),
        _ => const Color(0xFF273343),
      };

  void _paintFloor(Canvas canvas, Size size, Rect car) {
    final wet = mood == DriviqWeatherMood.rain || mood == DriviqWeatherMood.storm;
    final floorRect = Rect.fromCenter(
      center: Offset(size.width / 2, car.bottom - car.height * 0.03),
      width: car.width * 0.92,
      height: car.height * (wet ? 0.28 : 0.22),
    );
    final floor = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: wet ? 0.50 : 0.42),
          accent.withValues(alpha: wet ? 0.16 : 0.07),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(floorRect);
    canvas.drawOval(floorRect, floor);

    if (wet) {
      final reflection = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            accent.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ).createShader(floorRect);
      canvas.drawOval(floorRect.deflate(floorRect.height * 0.18), reflection);
    }
  }

  Path _bodyPath(Rect r) {
    final p = Path();
    switch (shape) {
      case PremiumVehicleShape.hatchback:
        p.moveTo(r.left + r.width * .08, r.top + r.height * .67);
        p.cubicTo(
          r.left + r.width * .14,
          r.top + r.height * .42,
          r.left + r.width * .26,
          r.top + r.height * .31,
          r.left + r.width * .39,
          r.top + r.height * .31,
        );
        p.lineTo(r.left + r.width * .64, r.top + r.height * .31);
        p.cubicTo(
          r.left + r.width * .78,
          r.top + r.height * .33,
          r.left + r.width * .91,
          r.top + r.height * .48,
          r.left + r.width * .95,
          r.top + r.height * .66,
        );
      case PremiumVehicleShape.suv:
        p.moveTo(r.left + r.width * .06, r.top + r.height * .66);
        p.cubicTo(
          r.left + r.width * .10,
          r.top + r.height * .40,
          r.left + r.width * .23,
          r.top + r.height * .25,
          r.left + r.width * .42,
          r.top + r.height * .24,
        );
        p.lineTo(r.left + r.width * .73, r.top + r.height * .25);
        p.cubicTo(
          r.left + r.width * .87,
          r.top + r.height * .31,
          r.left + r.width * .94,
          r.top + r.height * .49,
          r.left + r.width * .97,
          r.top + r.height * .66,
        );
      case PremiumVehicleShape.sport:
        p.moveTo(r.left + r.width * .05, r.top + r.height * .69);
        p.cubicTo(
          r.left + r.width * .19,
          r.top + r.height * .45,
          r.left + r.width * .37,
          r.top + r.height * .33,
          r.left + r.width * .53,
          r.top + r.height * .34,
        );
        p.cubicTo(
          r.left + r.width * .73,
          r.top + r.height * .35,
          r.left + r.width * .88,
          r.top + r.height * .48,
          r.left + r.width * .98,
          r.top + r.height * .66,
        );
      case PremiumVehicleShape.sedan:
        p.moveTo(r.left + r.width * .06, r.top + r.height * .67);
        p.cubicTo(
          r.left + r.width * .17,
          r.top + r.height * .45,
          r.left + r.width * .30,
          r.top + r.height * .31,
          r.left + r.width * .45,
          r.top + r.height * .30,
        );
        p.lineTo(r.left + r.width * .62, r.top + r.height * .30);
        p.cubicTo(
          r.left + r.width * .77,
          r.top + r.height * .32,
          r.left + r.width * .91,
          r.top + r.height * .48,
          r.left + r.width * .97,
          r.top + r.height * .66,
        );
    }
    p.lineTo(r.left + r.width * .93, r.top + r.height * .80);
    p.cubicTo(
      r.left + r.width * .76,
      r.top + r.height * .89,
      r.left + r.width * .27,
      r.top + r.height * .90,
      r.left + r.width * .10,
      r.top + r.height * .80,
    );
    p.close();
    return p;
  }

  void _paintBody(Canvas canvas, Rect r) {
    final body = _bodyPath(r);
    canvas.drawShadow(body, Colors.black.withValues(alpha: .70), 18, true);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_bodyTop, _bodyBottom],
        stops: const [0.0, 1.0],
      ).createShader(r);
    canvas.drawPath(body, paint);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: .55),
          accent.withValues(alpha: .18),
          Colors.black.withValues(alpha: .15),
        ],
      ).createShader(r);
    canvas.drawPath(body, rim);

    final highlightRect = Rect.fromLTWH(
      r.left + r.width * .12,
      r.top + r.height * .43,
      r.width * .76,
      r.height * .17,
    );
    final highlight = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withValues(alpha: .28), Colors.transparent],
      ).createShader(highlightRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlightRect, Radius.circular(r.height * .09)),
      highlight,
    );
  }

  void _paintGlass(Canvas canvas, Rect r) {
    final glass = Path()
      ..moveTo(r.left + r.width * .31, r.top + r.height * .38)
      ..cubicTo(
        r.left + r.width * .39,
        r.top + r.height * .23,
        r.left + r.width * .55,
        r.top + r.height * .21,
        r.left + r.width * .67,
        r.top + r.height * .38,
      )
      ..lineTo(r.left + r.width * .74, r.top + r.height * .55)
      ..lineTo(r.left + r.width * .24, r.top + r.height * .55)
      ..close();

    final p = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFEAFBFF).withValues(alpha: .34),
          const Color(0xFF07111B).withValues(alpha: .78),
        ],
      ).createShader(r);
    canvas.drawPath(glass, p);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .20);
    canvas.drawPath(glass, line);
  }

  void _paintDetails(Canvas canvas, Rect r) {
    if (_headlightsOn) {
      final beamRect = Rect.fromCenter(
        center: Offset(r.left + r.width * .91, r.top + r.height * .64),
        width: r.width * .22,
        height: r.height * .18,
      );
      final beam = Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: .42),
            accent.withValues(alpha: .12),
            Colors.transparent,
          ],
        ).createShader(beamRect);
      canvas.drawOval(beamRect, beam);
    }

    final frontLight = Paint()
      ..shader = RadialGradient(
        colors: [
          (_headlightsOn ? accent : Colors.white).withValues(alpha: .92),
          accent.withValues(alpha: .08),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(r.left + r.width * .91, r.top + r.height * .64),
          width: r.width * .14,
          height: r.height * .12,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(r.left + r.width * .91, r.top + r.height * .64),
        width: r.width * .08,
        height: r.height * .045,
      ),
      frontLight,
    );

    final rear = Paint()..color = const Color(0xFFFF4A5E).withValues(alpha: .72);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          r.left + r.width * .08,
          r.top + r.height * .63,
          r.width * .055,
          r.height * .035,
        ),
        const Radius.circular(8),
      ),
      rear,
    );

    final belt = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = Colors.white.withValues(alpha: .20);
    canvas.drawLine(
      Offset(r.left + r.width * .18, r.top + r.height * .61),
      Offset(r.left + r.width * .84, r.top + r.height * .61),
      belt,
    );
  }

  void _paintWheels(Canvas canvas, Rect r) {
    final wheelY = r.top + r.height * .79;
    final radius = r.height * .135;
    for (final x in [r.left + r.width * .25, r.left + r.width * .76]) {
      final c = Offset(x, wheelY);
      canvas.drawCircle(c, radius * 1.08, Paint()..color = Colors.black.withValues(alpha: .84));
      canvas.drawCircle(c, radius * .78, Paint()..color = const Color(0xFF101820));
      canvas.drawCircle(
        c,
        radius * .52,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: .62),
              const Color(0xFF556171),
              const Color(0xFF121923),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: radius)),
      );
      final spoke = Paint()
        ..color = Colors.white.withValues(alpha: .22)
        ..strokeWidth = 1.2;
      for (var i = 0; i < 6; i++) {
        final a = progress * math.pi * 2 + i * math.pi / 3;
        canvas.drawLine(c, c + Offset(math.cos(a), math.sin(a)) * radius * .48, spoke);
      }
    }
  }

  void _paintWeatherOnCar(Canvas canvas, Rect r) {
    if (mood == DriviqWeatherMood.snow) {
      final snow = Paint()..color = Colors.white.withValues(alpha: .78);
      final roof = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          r.left + r.width * .30,
          r.top + r.height * .27,
          r.width * .42,
          r.height * .035,
        ),
        const Radius.circular(20),
      );
      final hood = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          r.left + r.width * .68,
          r.top + r.height * .55,
          r.width * .18,
          r.height * .028,
        ),
        const Radius.circular(20),
      );
      canvas.drawRRect(roof, snow);
      canvas.drawRRect(hood, snow..color = Colors.white.withValues(alpha: .55));
    }
    if (mood == DriviqWeatherMood.rain || mood == DriviqWeatherMood.storm) {
      final wet = Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: .18), Colors.transparent],
        ).createShader(r);
      canvas.drawPath(_bodyPath(r), wet);
    }
    if (mood == DriviqWeatherMood.fog) {
      final mist = Paint()..color = const Color(0xFFEAF6FF).withValues(alpha: .06);
      canvas.drawPath(_bodyPath(r), mist);
    }
  }

  @override
  bool shouldRepaint(covariant PremiumVectorVehiclePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.mood != mood ||
      oldDelegate.shape != shape ||
      oldDelegate.accent != accent;
}
