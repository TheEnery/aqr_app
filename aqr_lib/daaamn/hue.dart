import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';

/// A simple container for a quantized color, its count, and its hue.
class ColorPeak {
  int color; // 24-bit color (quantized)
  int count; // number of occurrences
  double hue; // computed hue (0-360)

  ColorPeak(this.color, this.count, this.hue);
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

/// Extracts dominant colors from an image using a histogram built from a quantized color space,
/// then ordering by hue and grouping neighboring hues (with special red handling).
///
/// [image]: The source image.
/// [countThreshold]: Minimum count for a color to be considered.
/// [lsbReduction]: Number of least‐significant bits to discard (e.g. 2 means round to multiples of 4).
/// [hueThreshold]: Maximum hue difference (in degrees) for neighboring peaks to be grouped.
List<List<int>> extractDominantColorsByHue(
  Image image, {
  double threshold = 10,
  int lsbReduction = 2,
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

    int quantColor = (rQuant << 16) | (gQuant << 8) | bQuant;
    histogram[quantColor] = (histogram[quantColor] ?? 0) + 1;
  }

  // Step 2: Discard histogram peaks with counts below the threshold.
  Map<int, int> significantHistogram = {};
  histogram.forEach((color, count) {
    if (count >= countThreshold) {
      significantHistogram[color] = count;
    }
  });

  // Step 3: For each remaining peak, compute its hue and store as a ColorPeak.
  List<ColorPeak> peaks = [];
  significantHistogram.forEach((color, count) {
    int r = (color >> 16) & 0xFF;
    int g = (color >> 8) & 0xFF;
    int b = color & 0xFF;
    double hue = rgbToHue(r, g, b);
    peaks.add(ColorPeak(color, count, hue));
  });

  // Step 4: Order the peaks by hue.
  peaks.sort((a, b) => a.hue.compareTo(b.hue));

  // Step 5: Group neighboring peaks based on hue.
  // Two peaks are neighbors if their hue difference is <= hueThreshold.
  List<List<ColorPeak>> groups = [];
  List<ColorPeak> currentGroup = [];

  for (var peak in peaks) {
    if (currentGroup.isEmpty) {
      currentGroup.add(peak);
    } else {
      double diff = peak.hue - currentGroup.last.hue;
      if (diff <= hueThreshold) {
        currentGroup.add(peak);
      } else {
        groups.add(currentGroup);
        currentGroup = [peak];
      }
    }
  }
  if (currentGroup.isNotEmpty) {
    groups.add(currentGroup);
  }

  // Step 5b: Special handling for red hues.
  // If the first group starts with a hue very low (e.g. < hueThreshold)
  // and the last group ends with a hue very high (e.g. > 360 - hueThreshold),
  // merge them into one.
  if (groups.length > 1) {
    List<ColorPeak> firstGroup = groups.first;
    List<ColorPeak> lastGroup = groups.last;
    if (firstGroup.first.hue <= hueThreshold &&
        lastGroup.last.hue >= (360 - hueThreshold)) {
      List<ColorPeak> mergedGroup = [];
      mergedGroup.addAll(lastGroup);
      mergedGroup.addAll(firstGroup);
      groups[0] = mergedGroup;
      groups.removeLast();
    }
  }

  // Step 6: For each group, compute a weighted average color (weighted by the peak counts).
  List<List<int>> resultColors = [];
  for (var group in groups) {
    int totalCount = group.fold(0, (prev, peak) => prev + peak.count);
    double rSum = 0, gSum = 0, bSum = 0;
    for (var peak in group) {
      int count = peak.count;
      int r = (peak.color >> 16) & 0xFF;
      int g = (peak.color >> 8) & 0xFF;
      int b = peak.color & 0xFF;
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
