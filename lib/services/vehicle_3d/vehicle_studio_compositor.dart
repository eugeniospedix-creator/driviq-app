import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/dq_tokens.dart';
import '../../domain/entities/vehicle_3d_view_state.dart';
import '../../domain/enums/vehicle_view_mode.dart';
import 'vehicle_artwork_resolver.dart';

/// Hybrid compositor — pre-rendered vehicle artwork + live lighting, reflection,
/// and atmosphere layers. The car is an asset; the studio is code.
class VehicleStudioCompositor extends StatelessWidget {
  const VehicleStudioCompositor({
    super.key,
    required this.assetPath,
    required this.viewMode,
    required this.viewState,
    required this.scanning,
    required this.animationPhase,
    this.accentColor,
  });

  final String assetPath;
  final VehicleViewMode viewMode;
  final Vehicle3DViewState viewState;
  final bool scanning;
  final double animationPhase;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? DQ.cyan;
    final grade = VehicleArtworkResolver.gradeFor(viewMode);
    final t = animationPhase * math.pi * 2;
    final floatY = math.sin(t) * 3.5;
    final breathe = 1.0 + math.sin(t * 0.45) * 0.006;

    final panX = viewState.yaw * 28;
    final panY = viewState.pitch * 18 + grade.offsetY * 40;
    final scale = viewState.zoom.clamp(0.72, 1.38) * grade.zoom * breathe;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            _StudioAtmosphere(size: size, accent: accent, scanning: scanning, phase: t),
            _FloorGlow(size: size, accent: accent, scanning: scanning),
            _VehicleReflection(
              assetPath: assetPath,
              size: size,
              panX: panX,
              panY: panY + floatY,
              scale: scale,
            ),
            _VehicleHero(
              assetPath: assetPath,
              size: size,
              panX: panX,
              panY: panY + floatY,
              scale: scale,
              grade: grade,
            ),
            _LightingComposite(size: size, accent: accent, phase: t, scanning: scanning),
            _ParticleField(size: size, phase: t),
            if (scanning) _ScanSweep(size: size, phase: t),
            _Vignette(size: size),
          ],
        );
      },
    );
  }
}

class _StudioAtmosphere extends StatelessWidget {
  const _StudioAtmosphere({
    required this.size,
    required this.accent,
    required this.scanning,
    required this.phase,
  });

  final Size size;
  final Color accent;
  final bool scanning;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.42 + math.sin(phase * 0.6) * 4;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.15 + math.sin(phase * 0.3) * 0.02),
              radius: 1.1,
              colors: [
                DQ.graphite2.withValues(alpha: 0.5),
                DQ.voidBlack,
              ],
            ),
          ),
        ),
        Positioned(
          left: cx - size.width * 0.55,
          top: cy - size.height * 0.55,
          child: Container(
            width: size.width * 1.1,
            height: size.height * 0.75,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: scanning ? 0.18 : 0.11),
                  accent.withValues(alpha: scanning ? 0.04 : 0.02),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloorGlow extends StatelessWidget {
  const _FloorGlow({required this.size, required this.accent, required this.scanning});

  final Size size;
  final Color accent;
  final bool scanning;

  @override
  Widget build(BuildContext context) {
    final floorY = size.height * 0.72;
    return Positioned(
      left: size.width * 0.08,
      right: size.width * 0.08,
      top: floorY,
      child: Container(
        height: size.height * 0.08,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.9,
            colors: [
              accent.withValues(alpha: scanning ? 0.14 : 0.08),
              Colors.black.withValues(alpha: 0.35),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleHero extends StatelessWidget {
  const _VehicleHero({
    required this.assetPath,
    required this.size,
    required this.panX,
    required this.panY,
    required this.scale,
    required this.grade,
  });

  final String assetPath;
  final Size size;
  final double panX;
  final double panY;
  final double scale;
  final ViewModeGrade grade;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(panX, panY),
      child: Transform.scale(
        scale: scale,
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(_gradeMatrix(grade)),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            width: size.width,
            height: size.height * 0.78,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }

  List<double> _gradeMatrix(ViewModeGrade grade) {
    final b = grade.brightness;
    final w = grade.warmth;
    return [
      1, 0, 0, 0, b * 255 + w * 20,
      0, 1, 0, 0, b * 255,
      0, 0, 1, 0, b * 255 - w * 10,
      0, 0, 0, 1, 0,
    ];
  }
}

class _VehicleReflection extends StatelessWidget {
  const _VehicleReflection({
    required this.assetPath,
    required this.size,
    required this.panX,
    required this.panY,
    required this.scale,
  });

  final String assetPath;
  final Size size;
  final double panX;
  final double panY;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: size.height * 0.58,
      height: size.height * 0.22,
      child: ClipRect(
        child: Opacity(
          opacity: 0.22,
          child: Transform.translate(
            offset: Offset(panX, panY * 0.3),
            child: Transform.scale(
              scale: scale * 0.95,
              alignment: Alignment.topCenter,
              child: Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.rotationX(math.pi),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.transparent],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    width: size.width,
                    height: size.height * 0.78,
                    filterQuality: FilterQuality.low,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LightingComposite extends StatelessWidget {
  const _LightingComposite({
    required this.size,
    required this.accent,
    required this.phase,
    required this.scanning,
  });

  final Size size;
  final Color accent;
  final double phase;
  final bool scanning;

  @override
  Widget build(BuildContext context) {
    final sweepX = 0.15 + (math.sin(phase * 0.25) * 0.5 + 0.5) * 0.7;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + sweepX * 0.4, -0.8),
                end: Alignment(sweepX, 0.6),
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: scanning ? 0.06 : 0.035),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.1, -0.35),
                radius: 0.65,
                colors: [
                  accent.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticleField extends StatelessWidget {
  const _ParticleField({required this.size, required this.phase});

  final Size size;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _ParticlePainter(phase: phase, size: size),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.phase, required this.size});

  final double phase;
  final Size size;

  @override
  void paint(Canvas canvas, Size s) {
    for (var i = 0; i < 12; i++) {
      final seed = i * 2.399;
      final px = size.width * 0.5 + math.sin(phase * 0.35 + seed) * size.width * 0.28;
      final py = size.height * 0.35 + math.cos(phase * 0.42 + seed * 1.1) * size.height * 0.12;
      canvas.drawCircle(
        Offset(px, py),
        0.5 + (i % 2),
        Paint()..color = Colors.white.withValues(alpha: 0.04 + math.sin(phase + seed) * 0.03),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.phase != phase;
}

class _ScanSweep extends StatelessWidget {
  const _ScanSweep({required this.size, required this.phase});

  final Size size;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final x = size.width * (0.05 + 0.9 * ((phase / (math.pi * 2)) % 1.0));
    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: _ScanPainter(x: x, height: size.height),
      ),
    );
  }
}

class _ScanPainter extends CustomPainter {
  _ScanPainter({required this.x, required this.height});

  final double x;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final beam = size.width * 0.07;
    canvas.drawRect(
      Rect.fromLTWH(x - beam, height * 0.08, beam * 2, height * 0.84),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(x - beam, 0),
          Offset(x + beam, 0),
          [
            Colors.transparent,
            DQ.cyan.withValues(alpha: 0.12),
            DQ.cyan.withValues(alpha: 0.5),
            DQ.cyan.withValues(alpha: 0.12),
            Colors.transparent,
          ],
        )
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanPainter old) => old.x != x;
}

class _Vignette extends StatelessWidget {
  const _Vignette({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.95,
            colors: [
              Colors.transparent,
              DQ.voidBlack.withValues(alpha: 0.42),
            ],
            stops: const [0.55, 1.0],
          ),
        ),
      ),
    );
  }
}
