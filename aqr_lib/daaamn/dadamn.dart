// import 'dart:math';
// import 'dart:typed_data';

// import 'package:image/image.dart';

// List<int> itorgb(int i) => [(i >> 16) & 0xFF, (i >> 8) & 0xFF, i & 0xFF];

// int rgbtoi(List<int> rgb) => (rgb[0] << 16) | (rgb[1] << 8) | rgb[2];

// num distance(List<int> rgb1, List<int> rgb2) =>
//     (rgb1[0] - rgb2[0]).abs() +
//     (rgb1[1] - rgb2[1]).abs() +
//     (rgb1[2] - rgb2[2]).abs();

// List<int> avg(List<int> rgb1, int c1, List<int> rgb2, int c2) {
//   List<int> list = [];
//   for (int i = 0; i < 3; i++) {
//     list.add((rgb1[i] + (c1 / (c1 + c2)) * (rgb2[i] - rgb1[i])).toInt());
//   }
//   return list;
// }

// List<List<int>> extractHistogramPeaks(Image image, int numColors) {
//   Map<int, int> colorCount = {};
//   int maxDif = 16;

//   for (final pixel in image) {
//     int r = pixel.r.toInt(), g = pixel.g.toInt(), b = pixel.b.toInt();

//     int damn = 2;
//     r = (r >> damn) << damn;
//     g = (g >> damn) << damn;
//     b = (b >> damn) << damn;

//     final rgb = [r, g, b];
//     int color = rgbtoi(rgb); // Store as 24-bit int

//     colorCount[color] = (colorCount[color] ?? 0) + 1;
//   }

//   // Get the top `numColors` most frequent colors
//   List<int> topColors = colorCount.keys.toList()
//     ..sort((a, b) => colorCount[b]!.compareTo(colorCount[a]!));

//   List<int> top2 = [];
//   for (final c in topColors) {
//     var cr = itorgb(c);
//     for (int i = 0; i < top2.length; i++) {
//       final c2 = top2[i];
//       var cr2 = itorgb(c2);
//       if (distance(cr, cr2) < maxDif) {
//         top2[i] = rgbtoi(avg(cr, colorCount[c]!, cr2, colorCount[c2]!));
//       }
//     }
//   }

//   topColors
//       .take(numColors * 8)
//       .toList()
//       .forEach((c) => print('${colorCount[c]} ${itorgb(c)}'));

//   return topColors.take(numColors).map((c) => itorgb(c)).toList();
// }

//////////////////////////////////////////////////////////////////

import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';

/// Extracts dominant colors using histogram peaks with noise reduction and connected-component grouping.
/// [imageData] is the raw pixel data.
/// [width] and [height] are the dimensions of the image.
/// [countThreshold] is the minimum count a quantized color must have to be considered.
/// [lsbReduction] indicates how many least-significant bits to discard (e.g. 2).
List<List<int>> extractDominantColors(
  Uint8List imageData,
  int width,
  int height,
  double threshold, {
  int lsbReduction = 2,
}) {
  int countThreshold = (threshold * height * width).toInt();
  // --- Step 1: Build histogram with noise reduction ---
  // We quantize each channel by discarding the 'lsbReduction' bits.
  // For example, if lsbReduction==2, then we round each channel to the nearest multiple of 4.
  Map<int, int> histogram = {};
  int bytesPerPixel = imageData.length ~/ (width * height);

  for (int i = 0; i < imageData.length; i += bytesPerPixel) {
    int r = imageData[i];
    int g = imageData[i + 1];
    int b = imageData[i + 2];

    // Quantize by discarding lsbReduction bits.
    int rQuant = (r >> lsbReduction) << lsbReduction;
    int gQuant = (g >> lsbReduction) << lsbReduction;
    int bQuant = (b >> lsbReduction) << lsbReduction;

    // Combine channels into a single 24-bit integer.
    int quantColor = (rQuant << 16) | (gQuant << 8) | bQuant;
    histogram[quantColor] = (histogram[quantColor] ?? 0) + 1;
  }

  // double count = 0;
  // for (final v in histogram.values) {
  //   count += sqrt(v);
  // }

  //countThreshold = (count * count) ~/ histogram.length;

  // --- Step 2: Discard any peaks with a count less than threshold ---
  Map<int, int> significantHistogram = {};
  histogram.forEach((color, count) {
    if (count >= countThreshold) {
      significantHistogram[color] = count;
    }
  });

  // --- Step 3: Build the "graphs" (connected components) ---
  // Two peaks are considered neighbors if their per-channel differences are
  // at most the quantization step.
  int quantStep = 1 << lsbReduction; // e.g., 2 bits => step = 4

  bool areNeighbors(int c1, int c2) {
    int r1 = (c1 >> 16) & 0xFF;
    int g1 = (c1 >> 8) & 0xFF;
    int b1 = c1 & 0xFF;
    int r2 = (c2 >> 16) & 0xFF;
    int g2 = (c2 >> 8) & 0xFF;
    int b2 = c2 & 0xFF;
    return ((r1 - r2).abs() <= quantStep &&
        (g1 - g2).abs() <= quantStep &&
        (b1 - b2).abs() <= quantStep);
  }

  // Build a list of all significant colors.
  List<int> nodes = significantHistogram.keys.toList();

  // Use DFS to group connected peaks.
  Set<int> visited = {};
  List<List<int>> components = [];

  void dfs(int color, List<int> component) {
    visited.add(color);
    component.add(color);
    for (int neighbor in nodes) {
      if (!visited.contains(neighbor) && areNeighbors(color, neighbor)) {
        dfs(neighbor, component);
      }
    }
  }

  for (int color in nodes) {
    if (!visited.contains(color)) {
      List<int> component = [];
      dfs(color, component);
      components.add(component);
    }
  }

  // --- Step 4: For each connected component, compute weighted color ---
  // (weighted by the count in the histogram)
  List<List<int>> resultColors = [];
  for (List<int> component in components) {
    int totalCount = 0;
    double rSum = 0, gSum = 0, bSum = 0;
    for (int color in component) {
      int count = significantHistogram[color]!;
      totalCount += count;
      int r = (color >> 16) & 0xFF;
      int g = (color >> 8) & 0xFF;
      int b = color & 0xFF;
      rSum += r * count;
      gSum += g * count;
      bSum += b * count;
    }
    int avgR = (rSum / totalCount).round();
    int avgG = (gSum / totalCount).round();
    int avgB = (bSum / totalCount).round();
    resultColors.add([avgR, avgG, avgB]);
  }

  return resultColors;
}
