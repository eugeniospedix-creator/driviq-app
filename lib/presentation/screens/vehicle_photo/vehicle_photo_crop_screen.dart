import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/dq_tokens.dart';
import '../../../domain/entities/vehicle_photo_bounds.dart';

/// Manual crop fallback when automatic detection confidence is low.
class VehiclePhotoCropScreen extends StatefulWidget {
  const VehiclePhotoCropScreen({
    super.key,
    required this.imagePath,
    required this.initialBounds,
  });

  final String imagePath;
  final VehiclePhotoBounds initialBounds;

  @override
  State<VehiclePhotoCropScreen> createState() => _VehiclePhotoCropScreenState();
}

class _VehiclePhotoCropScreenState extends State<VehiclePhotoCropScreen> {
  late VehiclePhotoBounds _bounds;
  ui.Image? _image;
  _DragMode _dragMode = _DragMode.none;
  Offset? _dragStart;
  VehiclePhotoBounds? _boundsAtDragStart;

  @override
  void initState() {
    super.initState();
    _bounds = widget.initialBounds;
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await File(widget.imagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) setState(() => _image = frame.image);
  }

  Rect _boundsToRect(Size canvas) {
    return Rect.fromLTWH(
      _bounds.left * canvas.width,
      _bounds.top * canvas.height,
      _bounds.width * canvas.width,
      _bounds.height * canvas.height,
    );
  }

  _DragMode _hitTest(Offset local, Rect crop, Size canvas) {
    const handle = 28.0;
    final corners = {
      _DragMode.topLeft: crop.topLeft,
      _DragMode.topRight: crop.topRight,
      _DragMode.bottomLeft: crop.bottomLeft,
      _DragMode.bottomRight: crop.bottomRight,
    };
    for (final entry in corners.entries) {
      if ((local - entry.value).distance < handle) return entry.key;
    }
    if (crop.contains(local)) return _DragMode.move;
    return _DragMode.none;
  }

  void _onPanStart(DragStartDetails details, Size canvas) {
    final crop = _boundsToRect(canvas);
    _dragMode = _hitTest(details.localPosition, crop, canvas);
    _dragStart = details.localPosition;
    _boundsAtDragStart = _bounds;
  }

  void _onPanUpdate(DragUpdateDetails details, Size canvas) {
    if (_dragMode == _DragMode.none || _dragStart == null || _boundsAtDragStart == null) {
      return;
    }
    final start = _boundsAtDragStart!;
    final dx = details.localPosition.dx - _dragStart!.dx;
    final dy = details.localPosition.dy - _dragStart!.dy;
    final ndx = dx / canvas.width;
    final ndy = dy / canvas.height;

    setState(() {
      switch (_dragMode) {
        case _DragMode.move:
          _bounds = VehiclePhotoBounds(
            left: (start.left + ndx).clamp(0.0, 1.0 - start.width),
            top: (start.top + ndy).clamp(0.0, 1.0 - start.height),
            width: start.width,
            height: start.height,
          );
        case _DragMode.topLeft:
          _bounds = _resizeFromCorner(start, ndx, ndy, top: true, left: true);
        case _DragMode.topRight:
          _bounds = _resizeFromCorner(start, ndx, ndy, top: true, left: false);
        case _DragMode.bottomLeft:
          _bounds = _resizeFromCorner(start, ndx, ndy, top: false, left: true);
        case _DragMode.bottomRight:
          _bounds = _resizeFromCorner(start, ndx, ndy, top: false, left: false);
        case _DragMode.none:
          break;
      }
    });
  }

  VehiclePhotoBounds _resizeFromCorner(
    VehiclePhotoBounds start,
    double ndx,
    double ndy, {
    required bool top,
    required bool left,
  }) {
    var l = start.left;
    var t = start.top;
    var w = start.width;
    var h = start.height;

    if (left) {
      l = (start.left + ndx).clamp(0.0, start.left + start.width - 0.08);
      w = start.left + start.width - l;
    } else {
      w = (start.width + ndx).clamp(0.08, 1.0 - start.left);
    }
    if (top) {
      t = (start.top + ndy).clamp(0.0, start.top + start.height - 0.08);
      h = start.top + start.height - t;
    } else {
      h = (start.height + ndy).clamp(0.08, 1.0 - start.top);
    }

    return VehiclePhotoBounds(left: l, top: t, width: w, height: h);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DQ.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: DQ.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adjust crop',
          style: TextStyle(color: DQ.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 12),
            child: Text(
              'Frame your vehicle — drag corners or move the box for a clean studio cutout.',
              style: TextStyle(color: DQ.textMuted, fontSize: 13, height: 1.4),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final canvas = Size(constraints.maxWidth, constraints.maxHeight);
                  final crop = _boundsToRect(canvas);
                  return GestureDetector(
                    onPanStart: (d) => _onPanStart(d, canvas),
                    onPanUpdate: (d) => _onPanUpdate(d, canvas),
                    onPanEnd: (_) {
                      _dragMode = _DragMode.none;
                      _dragStart = null;
                      _boundsAtDragStart = null;
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DQ.radiusLg),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_image != null)
                            RawImage(image: _image, fit: BoxFit.cover)
                          else
                            const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: DQ.cyan),
                            ),
                          CustomPaint(
                            painter: _CropOverlayPainter(cropRect: crop),
                            size: canvas,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 18 + MediaQuery.paddingOf(context).bottom),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _bounds = widget.initialBounds),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DQ.textSecondary,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _bounds),
                    style: FilledButton.styleFrom(
                      backgroundColor: DQ.cyan,
                      foregroundColor: DQ.voidBlack,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Use crop', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _DragMode { none, move, topLeft, topRight, bottomLeft, bottomRight }

class _CropOverlayPainter extends CustomPainter {
  const _CropOverlayPainter({required this.cropRect});

  final Rect cropRect;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(full),
        Path()..addRect(cropRect),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.58),
    );

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = DQ.cyan.withValues(alpha: 0.92);
    canvas.drawRect(cropRect, border);

    final handle = Paint()..color = DQ.cyan;
    for (final corner in [
      cropRect.topLeft,
      cropRect.topRight,
      cropRect.bottomLeft,
      cropRect.bottomRight,
    ]) {
      canvas.drawCircle(corner, 7, handle);
      canvas.drawCircle(corner, 7, Paint()..color = DQ.voidBlack..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.18);
    for (var i = 1; i < 3; i++) {
      final x = cropRect.left + cropRect.width * i / 3;
      final y = cropRect.top + cropRect.height * i / 3;
      canvas.drawLine(Offset(x, cropRect.top), Offset(x, cropRect.bottom), grid);
      canvas.drawLine(Offset(cropRect.left, y), Offset(cropRect.right, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) =>
      oldDelegate.cropRect != cropRect;
}
