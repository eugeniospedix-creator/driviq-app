import 'package:image/image.dart' as img;

import '../../domain/entities/vehicle_photo_bounds.dart';

({int left, int top, int width, int height}) photoBoundsToPixelRect(
  int imageW,
  int imageH,
  VehiclePhotoBounds bounds,
) {
  final left = (bounds.left * imageW).round().clamp(0, imageW - 1);
  final top = (bounds.top * imageH).round().clamp(0, imageH - 1);
  final width = (bounds.width * imageW).round().clamp(1, imageW - left);
  final height = (bounds.height * imageH).round().clamp(1, imageH - top);
  return (left: left, top: top, width: width, height: height);
}

VehiclePhotoBounds clampBounds(VehiclePhotoBounds bounds) {
  var left = bounds.left.clamp(0.0, 0.95);
  var top = bounds.top.clamp(0.0, 0.95);
  var width = bounds.width.clamp(0.08, 1.0 - left);
  var height = bounds.height.clamp(0.08, 1.0 - top);
  return VehiclePhotoBounds(left: left, top: top, width: width, height: height);
}

/// Expands bounds with premium studio margin so wheels/roof are not clipped.
VehiclePhotoBounds premiumMarginBounds(VehiclePhotoBounds bounds, {double margin = 0.10}) {
  final b = clampBounds(bounds);
  final m = margin;
  final left = (b.left - b.width * m).clamp(0.0, 0.92);
  final top = (b.top - b.height * m).clamp(0.0, 0.92);
  final right = (b.left + b.width + b.width * m).clamp(left + 0.08, 1.0);
  final bottom = (b.top + b.height + b.height * m).clamp(top + 0.08, 1.0);
  return VehiclePhotoBounds(left: left, top: top, width: right - left, height: bottom - top);
}

img.Image resizeIfNeeded(img.Image source, {int maxSide = 1400}) {
  if (source.width <= maxSide && source.height <= maxSide) return source;
  return img.copyResize(
    source,
    width: source.width >= source.height ? maxSide : null,
    height: source.height > source.width ? maxSide : null,
  );
}

/// Samples corner pixels to estimate background colour.
({int r, int g, int b}) estimateBackgroundColor(img.Image image) {
  var r = 0, g = 0, b = 0, n = 0;
  final samples = <({int x, int y})>[
    (x: 0, y: 0),
    (x: image.width - 1, y: 0),
    (x: 0, y: image.height - 1),
    (x: image.width - 1, y: image.height - 1),
    (x: image.width ~/ 2, y: 0),
    (x: image.width ~/ 2, y: image.height - 1),
  ];
  for (final s in samples) {
    final p = image.getPixel(s.x, s.y);
    r += p.r.toInt();
    g += p.g.toInt();
    b += p.b.toInt();
    n++;
  }
  return (r: r ~/ n, g: g ~/ n, b: b ~/ n);
}

double colorDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
  final dr = r1 - r2;
  final dg = g1 - g2;
  final db = b1 - b2;
  return (dr * dr + dg * dg + db * db).toDouble();
}

double pixelLuminance(img.Pixel pixel) =>
    0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;

/// Flood-fill background removal from edges + feathered alpha matte.
img.Image removeBackgroundPremium(img.Image source) {
  final w = source.width;
  final h = source.height;
  final bg = estimateBackgroundColor(source);
  final isBg = List.generate(w * h, (_) => false);
  final queue = <int>[];

  void tryPush(int x, int y) {
    if (x < 0 || y < 0 || x >= w || y >= h) return;
    final i = y * w + x;
    if (isBg[i]) return;
    final p = source.getPixel(x, y);
    final dist = colorDistance(p.r.toInt(), p.g.toInt(), p.b.toInt(), bg.r, bg.g, bg.b);
    if (dist < 2800) {
      isBg[i] = true;
      queue.add(i);
    }
  }

  for (var x = 0; x < w; x++) {
    tryPush(x, 0);
    tryPush(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    tryPush(0, y);
    tryPush(w - 1, y);
  }

  while (queue.isNotEmpty) {
    final i = queue.removeLast();
    final x = i % w;
    final y = i ~/ w;
    tryPush(x - 1, y);
    tryPush(x + 1, y);
    tryPush(x, y - 1);
    tryPush(x, y + 1);
  }

  final out = img.Image(width: w, height: h, numChannels: 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = source.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final lum = pixelLuminance(p);
      final dist = colorDistance(r, g, b, bg.r, bg.g, bg.b);

      var alpha = isBg[y * w + x] ? 0.0 : 1.0;
      if (alpha > 0 && dist < 4200) {
        alpha = (dist / 4200).clamp(0.0, 1.0);
      }
      if (lum > 215 && dist < 5000) alpha *= 0.22;
      if (lum < 30) alpha = alpha < 0.5 ? 0.82 : alpha;

      final edgeX = (x < 3 || x > w - 4) ? 0.65 : 1.0;
      final edgeY = (y < 3 || y > h - 4) ? 0.65 : 1.0;
      alpha *= edgeX * edgeY;

      out.setPixelRgba(x, y, r, g, b, (alpha * 255).round().clamp(0, 255));
    }
  }
  return out;
}

/// Subtle studio contrast + lift for transparent vehicle cutouts.
img.Image enhanceStudioLighting(img.Image source) {
  final out = img.Image.from(source);
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final p = out.getPixel(x, y);
      final a = p.a.toInt();
      if (a < 8) continue;
      var r = p.r.toInt() / 255.0;
      var g = p.g.toInt() / 255.0;
      var b = p.b.toInt() / 255.0;
      r = ((r - 0.5) * 1.08 + 0.52).clamp(0.0, 1.0);
      g = ((g - 0.5) * 1.08 + 0.52).clamp(0.0, 1.0);
      b = ((b - 0.5) * 1.08 + 0.52).clamp(0.0, 1.0);
      out.setPixelRgba(
        x,
        y,
        (r * 255).round(),
        (g * 255).round(),
        (b * 255).round(),
        a,
      );
    }
  }
  return out;
}

/// Pads crop with transparent margin for premium framing.
img.Image addPremiumCanvasPadding(img.Image source, {double padRatio = 0.08}) {
  final padX = (source.width * padRatio).round();
  final padY = (source.height * padRatio).round();
  final out = img.Image(
    width: source.width + padX * 2,
    height: source.height + padY * 2,
    numChannels: 4,
  );
  img.compositeImage(out, source, dstX: padX, dstY: padY);
  return out;
}
