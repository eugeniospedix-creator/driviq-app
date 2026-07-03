import 'package:flutter/material.dart';

import '../launch/driviq_logo_geometry.dart';
import 'home_vehicle_body_type.dart';

/// Side-profile sedan geometry — directly derived from the approved Driviq icon silhouette.
abstract final class HomeVehicleSilhouetteGeometry {
  static Rect bounds(Size size) {
    final carW = size.width * 0.90;
    final carH = size.height * 0.40;
    return Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.57),
      width: carW,
      height: carH,
    );
  }

  static Path bodyPath(HomeVehicleBodyType type, Rect b) {
    return _transform(_rawBody(type), b);
  }

  static Path glassPath(HomeVehicleBodyType type, Rect b) {
    return _transform(_rawGlass(type), b);
  }

  static Path rockerPath(HomeVehicleBodyType type, Rect b) {
    return _transform(_rawRocker(type), b);
  }

  static List<WheelLayout> wheels(HomeVehicleBodyType type, Rect b) {
    return _rawWheels(type).map((w) => w.map(b)).toList();
  }

  static Path _rawBody(HomeVehicleBodyType type) {
    final scaleX = switch (type) {
      HomeVehicleBodyType.compactSedan => 0.94,
      HomeVehicleBodyType.executiveSedan => 1.06,
      _ => 1.0,
    };
    final base = switch (type) {
      HomeVehicleBodyType.evSedan => _evSideBody(),
      _ => _sportSideBody(),
    };
    if (scaleX == 1.0) return base;
    return _scalePathX(base, scaleX);
  }

  static Path _rawGlass(HomeVehicleBodyType type) => switch (type) {
        HomeVehicleBodyType.evSedan => _evSideGlass(),
        HomeVehicleBodyType.compactSedan => _compactSideGlass(),
        _ => _sportSideGlass(),
      };

  static Path _rawRocker(HomeVehicleBodyType type) {
    final wheels = _rawWheels(type);
    final p = Path();
    p.moveTo(0.08, 0.60);
    p.lineTo(wheels[1].cx - wheels[1].rx * 1.1, 0.60);
    p.quadraticBezierTo(wheels[1].cx, 0.82, wheels[1].cx + wheels[1].rx * 1.1, 0.60);
    p.lineTo(wheels[0].cx - wheels[0].rx * 1.1, 0.60);
    p.quadraticBezierTo(wheels[0].cx, 0.82, wheels[0].cx + wheels[0].rx * 1.1, 0.60);
    p.lineTo(0.92, 0.60);
    return p;
  }

  static List<WheelLayoutNorm> _rawWheels(HomeVehicleBodyType type) {
    final rearX = switch (type) {
      HomeVehicleBodyType.executiveSedan => 0.24,
      HomeVehicleBodyType.compactSedan => 0.30,
      _ => 0.27,
    };
    final frontX = switch (type) {
      HomeVehicleBodyType.executiveSedan => 0.76,
      HomeVehicleBodyType.compactSedan => 0.70,
      _ => 0.73,
    };
    final r = switch (type) {
      HomeVehicleBodyType.evSedan => 0.108,
      HomeVehicleBodyType.compactSedan => 0.098,
      _ => 0.104,
    };
    return [
      WheelLayoutNorm(frontX, 0.70, r, r),
      WheelLayoutNorm(rearX, 0.70, r, r),
    ];
  }

  /// Logo roofline + realistic side profile — sport / BMW.
  static Path _sportSideBody() {
    final roof = DriviqLogoGeometry.topStroke();
    return Path()
      ..moveTo(0.92, 0.58)
      ..lineTo(0.965, 0.50)
      ..lineTo(0.94, 0.44)
      ..lineTo(0.86, 0.52)
      ..addPath(roof, Offset.zero)
      ..lineTo(0.08, 0.58)
      ..lineTo(0.10, 0.62)
      ..lineTo(0.92, 0.62)
      ..close();
  }

  static Path _evSideBody() {
    return Path()
      ..moveTo(0.94, 0.56)
      ..cubicTo(0.98, 0.48, 0.97, 0.38, 0.88, 0.36)
      ..lineTo(0.82, 0.50)
      ..cubicTo(0.78, 0.42, 0.62, 0.30, 0.46, 0.26)
      ..cubicTo(0.30, 0.22, 0.16, 0.30, 0.12, 0.48)
      ..lineTo(0.08, 0.56)
      ..lineTo(0.10, 0.62)
      ..lineTo(0.94, 0.62)
      ..close();
  }

  static Path _sportSideGlass() {
    return Path()
      ..moveTo(0.82, 0.50)
      ..lineTo(0.74, 0.30)
      ..cubicTo(0.58, 0.22, 0.38, 0.24, 0.22, 0.38)
      ..lineTo(0.18, 0.50)
      ..lineTo(0.78, 0.50)
      ..close();
  }

  static Path _evSideGlass() {
    return Path()
      ..moveTo(0.80, 0.48)
      ..cubicTo(0.68, 0.32, 0.48, 0.28, 0.28, 0.36)
      ..lineTo(0.20, 0.48)
      ..lineTo(0.76, 0.48)
      ..close();
  }

  static Path _compactSideGlass() {
    return Path()
      ..moveTo(0.80, 0.50)
      ..lineTo(0.72, 0.32)
      ..cubicTo(0.56, 0.24, 0.40, 0.26, 0.24, 0.40)
      ..lineTo(0.20, 0.50)
      ..close();
  }

  static Path _scalePathX(Path path, double scaleX) {
    final bounds = path.getBounds();
    final cx = bounds.center.dx;
    final matrix = Matrix4.identity()
      ..translateByDouble(cx, 0.0, 0, 1)
      ..scaleByDouble(scaleX, 1.0, 1, 1)
      ..translateByDouble(-cx, 0.0, 0, 1);
    return path.transform(matrix.storage);
  }

  static Path _transform(Path normalized, Rect bounds) {
    final matrix = Matrix4.identity()
      ..translateByDouble(bounds.left, bounds.top, 0, 1)
      ..scaleByDouble(bounds.width, bounds.height, 1, 1);
    return normalized.transform(matrix.storage);
  }
}

class WheelLayoutNorm {
  const WheelLayoutNorm(this.cx, this.cy, this.rx, this.ry);

  final double cx;
  final double cy;
  final double rx;
  final double ry;

  WheelLayout map(Rect b) => WheelLayout(
        center: Offset(b.left + cx * b.width, b.top + cy * b.height),
        radiusX: rx * b.width,
        radiusY: ry * b.height,
      );
}

class WheelLayout {
  const WheelLayout({
    required this.center,
    required this.radiusX,
    required this.radiusY,
  });

  final Offset center;
  final double radiusX;
  final double radiusY;
}
