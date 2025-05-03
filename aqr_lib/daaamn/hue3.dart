import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:image/image.dart';
import 'package:zxing_lib/src/core/byte4_matrix.dart';

void main() {
  final image = decodePng(File('image.png').readAsBytesSync());

  List<List<int>> peaks = extractDominantColorsByHue(image!);

  int numColors = peaks.length;

  final paletteImg = Image(width: 400, height: 100);
  for (int i = 0; i < numColors; i++) {
    final color = ColorRgb8(peaks[i][0], peaks[i][1], peaks[i][2]);
    fillRect(
      paletteImg,
      x1: (i % 8) * 50,
      y1: 50 * (i ~/ 8),
      x2: ((i % 8) + 1) * 50,
      y2: 100,
      color: color,
    );
    print(color);
  }

  File('palette.png').writeAsBytesSync(encodePng(paletteImg));
}

Color rgbtoc(List<int> rgb) => ColorRgb8(rgb[0], rgb[1], rgb[2]);

class ColorPeak {
  int color; // 24-bit color (quantized)
  int count; // number of occurrences
  double hue; // computed hue (0-360)
  double saturation;

  ColorPeak(this.color, this.count, this.hue, this.saturation);
}

double rgbToH(List<int> l) => rgbToHue(l[0], l[1], l[2]);

/// Convert an RGB color (0-255 per channel) to its hue (0-360).
double rgbToHue(int r, int g, int b) {
  double rd = r / 255.0;
  double gd = g / 255.0;
  double bd = b / 255.0;
  double maxVal = max(rd, max(gd, bd));
  double minVal = min(rd, min(gd, bd));
  double delta = maxVal - minVal;
  double hue = 0.0;
  if (delta == 0) {
    hue = 0;
  } else if (maxVal == rd) {
    hue = 60 * (((gd - bd) / delta) % 6);
  } else if (maxVal == gd) {
    hue = 60 * (((bd - rd) / delta) + 2);
  } else {
    // maxVal == bd
    hue = 60 * (((rd - gd) / delta) + 4);
  }
  if (hue < 0) hue += 360;
  return hue;
}

double rgbToS(List<int> l) => rgbToSaturation(l[0], l[1], l[2]);

double rgbToSaturation(int r, int g, int b) {
  double rd = r / 255.0;
  double gd = g / 255.0;
  double bd = b / 255.0;
  double maxVal = max(rd, max(gd, bd));
  double minVal = min(rd, min(gd, bd));
  double delta = maxVal - minVal;
  return maxVal == 0 ? 0 : delta / maxVal;
}

List<List<int>> extractDominantColorsByHue(
  Image image, {
  double threshold = 0,
  int lsbReduction = 0,
  double hueThreshold = 20.0,
}) {
  int countThreshold = (threshold * image.height * image.width).toInt();
  Uint8List imageData = image.getBytes();
  int width = image.width;
  int height = image.height;
  int bytesPerPixel = imageData.length ~/ (width * height);

  // Step 1: Build a quantized histogram.
  // Quantize each channel by discarding the lsbReduction bits.
  Map<int, int> histogram = {};
  for (int i = 0; i < imageData.length; i += bytesPerPixel) {
    int r = imageData[i];
    int g = imageData[i + 1];
    int b = imageData[i + 2];

    int rQuant = (r >> lsbReduction) << lsbReduction;
    int gQuant = (g >> lsbReduction) << lsbReduction;
    int bQuant = (b >> lsbReduction) << lsbReduction;

    int quantColor = (rQuant << 8) | (gQuant << 16) | (bQuant << 24);
    histogram[quantColor] = (histogram[quantColor] ?? 0) + 1;
  }

  // Step 2: Discard histogram peaks with counts below the threshold.
  Map<int, int> significantHistogram = {};
  histogram.forEach((color, count) {
    if (count >= countThreshold) {
      significantHistogram[color] = count;
    }
  });

  List<int> merge(List<int> cs) {
    int rs = 0, gs = 0, bs = 0, sum = 0;
    for (final c in cs) {
      var count = significantHistogram[c]!;
      var [_, r, g, b] = c.to4ByteList();
      rs += r * count;
      gs += g * count;
      bs += b * count;
      sum += count;
    }
    return [(rs / sum).round(), (gs / sum).round(), (bs / sum).round()];
  }

  var wPeaks = significantHistogram.keys.where((c) {
    var [l, r, g, b] = c.to4ByteList();
    return 0.2126 * r + 0.7152 * g + 0.0722 * b > 230;
  }).toList();
  var kPeaks = significantHistogram.keys.where((c) {
    var [l, r, g, b] = c.to4ByteList();
    return 0.2126 * r + 0.7152 * g + 0.0722 * b < 20;
  }).toList();

  var white = merge(wPeaks);
  var black = merge(kPeaks);

  print(white);
  print(black);

  significantHistogram
      .removeWhere((k, v) => wPeaks.contains(k) || kPeaks.contains(k));

  // Step 3: For each remaining peak, compute its hue and store as a ColorPeak.
  List<ColorPeak> peaks = [];
  significantHistogram.forEach((color, count) {
    int r = (color >> 8) & 0xFF;
    int g = (color >> 16) & 0xFF;
    int b = (color >> 24) & 0xFF;
    double hue = rgbToHue(r, g, b);
    double saturation = rgbToSaturation(r, g, b);
    peaks.add(ColorPeak(color, count, hue, saturation));
  });

  var grays = peaks.where((p) => p.saturation < 0.2).toList();
  peaks.removeWhere((p) => grays.contains(p));

  var wgrgb = hslToRgb(0, 0, 0.75);
  var wgcc = 1;

  var kgrgb = hslToRgb(0, 0, 0.25);
  var kgcc = 1;

  for (final c in grays) {
    var [_, r, g, b] = c.color.to4ByteList();
    if (0.2126 * r + 0.7152 * g + 0.0722 * b < 128) {
      kgrgb[0] += r * c.count;
      kgrgb[1] += g * c.count;
      kgrgb[2] += b * c.count;
      kgcc += c.count;
    } else {
      wgrgb[0] += r * c.count;
      wgrgb[1] += g * c.count;
      wgrgb[2] += b * c.count;
      wgcc += c.count;
    }
  }

  kgrgb = [
    (kgrgb[0] / kgcc).round(),
    (kgrgb[1] / kgcc).round(),
    (kgrgb[2] / kgcc).round()
  ];
  wgrgb = [
    (wgrgb[0] / wgcc).round(),
    (wgrgb[1] / wgcc).round(),
    (wgrgb[2] / wgcc).round()
  ];

  // Step 4: Order the peaks by hue.
  peaks.sort((a, b) => a.hue.compareTo(b.hue));

  groupBy(peaks, (p) => p.hue.toInt()).forEach((h, p) {
    print(h.toInt().toString() +
        ("h" * (p.fold(0, (int a, b) => a + b.count) * 100 ~/ peaks.length)));
  });

  double divider = 1 / 6;
  double C = 0, S = 0;
  for (final p in peaks) {
    final nHue = p.hue / 360;
    final remainder = nHue.remainder(divider);
    final theta = 2 * pi * remainder / divider;
    C += p.count * cos(theta);
    S += p.count * sin(theta);
  }
  double thetaMean = atan2(S, C);
  double shift = divider * thetaMean * 360 / (2 * pi);

  print(shift);

  ////

  double groupShift = divider * 180 - shift;
  final groups = groupBy(peaks,
      (p) => (((p.hue + groupShift + 360) % 360) / (360 * divider)).toInt());

  ///

  List<List<int>> ks = [], ws = [];

  for (final kvs in groups.entries.sorted((a, b) => a.key.compareTo(b.key))) {
    final cs = kvs.value;

    final wrgb = hslToRgb(kvs.key * divider + shift / 360, 1, 0.75);
    var wcc = 1;

    final krgb = hslToRgb(kvs.key * divider + shift / 360, 1, 0.25);
    var kcc = 1;

    for (final c in cs) {
      var [_, r, g, b] = c.color.to4ByteList();
      if (0.2126 * r + 0.7152 * g + 0.0722 * b < 128) {
        krgb[0] += r * c.count;
        krgb[1] += g * c.count;
        krgb[2] += b * c.count;
        kcc += c.count;
      } else {
        wrgb[0] += r * c.count;
        wrgb[1] += g * c.count;
        wrgb[2] += b * c.count;
        wcc += c.count;
      }
    }

    ks.add([
      (krgb[0] / kcc).round(),
      (krgb[1] / kcc).round(),
      (krgb[2] / kcc).round()
    ]);
    ws.add([
      (wrgb[0] / wcc).round(),
      (wrgb[1] / wcc).round(),
      (wrgb[2] / wcc).round()
    ]);
  }

  return [white, ...ws, wgrgb, black, ...ks, kgrgb];
}
