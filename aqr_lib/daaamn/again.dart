import 'dart:math';

import 'package:collection/collection.dart';
import 'package:image/image.dart';
import 'package:zxing_lib/src/core/compression.dart';

import 'hue.dart';

/// Container for a distinct color entry with its weighted average and occurrence count.
class ColorEntry {
  double r, g, b;
  int count;

  ColorEntry(this.r, this.g, this.b, this.count);

  /// Updates this entry by merging in a new color (cr, cg, cb) with weight 1.
  void merge(double cr, double cg, double cb) {
    r = (r * count + cr) / (count + 1);
    g = (g * count + cg) / (count + 1);
    b = (b * count + cb) / (count + 1);
    count++;
  }

  @override
  String toString() {
    return '($count: $r $g $b)';
  }
}

/// Computes a simplified distance between two colors using sum of absolute differences.
int simplifiedDistance(
    double r1, double g1, double b1, double r2, double g2, double b2) {
  return ((r1 - r2).abs() + (g1 - g2).abs() + (b1 - b2).abs()).round();
}

/// Traverses the image in zigzag order and collects distinct colors.
/// [minOccurrence] defines the minimum count required for a color to be kept.
/// [distanceThreshold] is the maximum allowed sum-of-absolute-differences to merge two colors.
List<List<int>> extractDistinctColorsZigzag(
  Image image, {
  int minOccurrence = 5,
  int distanceThreshold = 150,
}) {
  List<ColorEntry> distinctColors = [];
  // Compression.defaultPalette[3]
  //     .toList()
  //     .map((c) =>
  //         ColorEntry(c.r.toDouble(), c.g.toDouble(), c.b.toDouble(), 10))
  //     .toList();

  // Local helper: process the pixel at (x, y)
  void processPixel(int x, int y) {
    Pixel pixel = image.getPixel(x, y);
    var r = (pixel.r.toDouble());
    var g = (pixel.g.toDouble());
    var b = (pixel.b.toDouble());

    // Find the most similar distinct color.
    int bestDistance = 1 << 30; // large number
    ColorEntry? bestCandidate;

    for (ColorEntry candidate in distinctColors) {
      int dist =
          simplifiedDistance(candidate.r, candidate.g, candidate.b, r, g, b);
      if (dist < bestDistance) {
        bestDistance = dist;
        bestCandidate = candidate;
      }
    }

    // If a candidate exists and is similar enough, merge; otherwise, add as new.
    if (bestCandidate != null && bestDistance < distanceThreshold) {
      bestCandidate.merge(r, g, b);
    } else {
      distinctColors
          .add(ColorEntry(r.toDouble(), g.toDouble(), b.toDouble(), 1));
    }
  }

  // Zigzag traversal: even rows left-to-right, odd rows right-to-left.
  //for (int y = image.height - 1; y >= 0; y--) {
  for (int y = 0; y < image.height; y++) {
    if (y % 2 == 0) {
      // left-to-right
      for (int x = 0; x < image.width; x++) {
        processPixel(x, y);
      }
    } else {
      // right-to-left
      for (int x = image.width - 1; x >= 0; x--) {
        processPixel(x, y);
      }
    }
  }
  print(distinctColors);

  var filtered =
      distinctColors.where((entry) => entry.count >= minOccurrence).toList();

  var level = (log(filtered.length) / log(2)).toInt() - 1;
  level = level.clamp(0, 3);
  final length = 2 << level;

  double getL(ColorEntry l) => 0.2126 * l.r + 0.7152 * l.g + 0.0722 * l.b;
  double rgbToH(ColorEntry l) =>
      rgbToHue(l.r.toInt(), l.g.toInt(), l.b.toInt());

  var whites = filtered.where((p) => getL(p) > 230);
  var blacks = filtered.where((p) => getL(p) < 25);

  var gbh = groupBy(filtered, (p) => (((rgbToH(p) - 60) + 360) % 360 ~/ 60));

  // if (length != filtered.length) {
  //   filtered.sort((c1, c2) => c2.count.compareTo(c1.count));
  //   filtered = filtered.take(length).toList();
  // }
  // while (length != filtered.length) {
  //   int bestDistance = 0xFFFF;
  //   late List<ColorEntry> best;
  //   for (var i = 0; i < filtered.length; i++) {
  //     for (var j = i + 1; j < filtered.length; j++) {
  //       final c1 = filtered[i];
  //       final c2 = filtered[j];
  //       final distance = simplifiedDistance(
  //           c1.r, c1.g, c1.b, c2.r, c2.g, c2.b); //* lumDif(c1, c2);
  //       if (bestDistance > distance) {
  //         bestDistance = distance;
  //         best = [c1, c2];
  //       }
  //     }
  //   }

  //   var [c1, c2] = best;
  //   filtered.remove(c1);
  //   filtered.remove(c2);
  //   var count = c1.count + c2.count;
  //   filtered.add(ColorEntry(
  //     (c1.r * c1.count + c2.r * c2.count) / count,
  //     (c1.g * c1.count + c2.g * c2.count) / count,
  //     (c1.b * c1.count + c2.b * c2.count) / count,
  //     count,
  //   ));
  // }

  // Now filter out colors with count less than minOccurrence.
  List<List<int>> result = filtered
      .map((entry) => [entry.r.round(), entry.g.round(), entry.b.round()])
      .toList();

  return result;
}

int lumDif(ColorEntry c1, ColorEntry c2) =>
    (ColorRgb8(c1.r.toInt(), c1.g.toInt(), c1.b.toInt()).luminance -
            ColorRgb8(c2.r.toInt(), c2.g.toInt(), c2.b.toInt()).luminance)
        .abs()
        .toInt();
