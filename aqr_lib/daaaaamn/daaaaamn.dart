import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:image/image.dart' hide Decoder, Encoder, rgbToLab;
import 'package:zxing_lib/src/core/aqr_meta.dart';
import 'package:zxing_lib/src/core/byte4_matrix.dart';
import 'package:zxing_lib/src/core/compression.dart';
import 'package:zxing_lib/src/core/mask.dart';
import 'package:zxing_lib/src/decoder/decoder.dart';
import 'package:zxing_lib/src/decolorizer/unmap.dart';
import 'package:zxing_lib/src/detector/detector.dart';
import 'package:zxing_lib/src/detector/global_histogram_binarizer.dart';
import 'package:zxing_lib/src/encoder/encoder.dart';

import '../daaamn/again.dart';
import '../daaamn/daaamn.dart';
//import '../daaamn/hue3.dart';

void main() {
  /// reading
  final image = decodePng(File('image.png').readAsBytesSync())!;

  final byteImage = Byte4Matrix(height: image.height, width: image.width);

  for (int x = 0; x < image.width; x++) {
    for (int y = 0; y < image.height; y++) {
      final p = image.getPixel(x, y);
      byteImage[x][y] = [
        p.luminance.toInt(),
        p.r.toInt(),
        p.g.toInt(),
        p.b.toInt(),
      ].to4ByteUint();
    }
  }

  /// binarization
  GlobalHistogramBinarizer(byteImage).blackMatrix;

  final wbImage = Image(width: image.width, height: image.height);
  final wh = ColorRgb8(255, 255, 255), b = ColorRgb8(0, 0, 0);

  for (int x = 0; x < image.width; x++) {
    for (int y = 0; y < image.height; y++) {
      wbImage.setPixel(x, y, byteImage[x][y] & 1 == 1 ? b : wh);
    }
  }

  File('1_wbImage.png').writeAsBytesSync(encodePng(wbImage));

  /// detecting
  final result = Detector(byteImage).detect().bits;

  final wbDetectedImage = Image(width: result.width, height: result.height);

  for (int x = 0; x < wbDetectedImage.width; x++) {
    for (int y = 0; y < wbDetectedImage.height; y++) {
      final lrgb = result[x][y].to4ByteList();

      wbDetectedImage.setPixel(x, y, lrgb[0] == 1 ? b : wh);
    }
  }

  File('2_detectedImage.png').writeAsBytesSync(encodePng(result.toImage()));

  File('3_wbDetectedImage.png').writeAsBytesSync(encodePng(wbDetectedImage));

  /// balancing
  // result.applyGamma(2.2);
  result.balanceColorsFromFinders();

  File('4_colorCorrectedImage.png')
      .writeAsBytesSync(encodePng(result.toImage()));

  /// gamma decoding
  // result.balanceColorsFromFinders();
  result.applyGamma(2.2);
  var resultImg = result.toImage();
  File('5_gammaDetectedImage.png').writeAsBytesSync(encodePng(resultImg));

  /// palette extracting
  //var peaks = extractDominantColorsByHue(resultImg);

  //extractDistinctColorsZigzag(result.toImage(),
  //   distanceThreshold: 60, minOccurrence: 0);
  // .map((rgb) => ColorRgb8(rgb[0], rgb[1], rgb[2]) as Color)
  // .toList();
////
////
  // var numColors = peaks.length;

  // peaks.sort((c1, c2) => rgbtoc(c2).luminance.compareTo(rgbtoc(c1).luminance));

  // final w = peaks.first;
  // final k = peaks.last;
  // final ws = peaks.skip(1).take(numColors ~/ 2 - 1).toList()
  //   ..sort((a, b) => rgbToH(a).compareTo(rgbToH(b)));
  // final ks = peaks
  //     .skip(1 + numColors ~/ 2 - 1)
  //     .take(numColors ~/ 2 - 1)
  //     .toList()
  //   ..sort((a, b) => rgbToH(a).compareTo(H(b)));

  // peaks = [w, ...ws, ...ks.reversed, k];

  // //nudgeLumas(peaks);

  // //peaks = peaks.reversed.toList();
  // final middle = numColors ~/ 2;
  // peaks.setAll(middle, peaks.sublist(middle).reversed);

  // var palette =
  //     peaks.map((rgb) => ColorRgb8(rgb[0], rgb[1], rgb[2]) as Color).toList();
////

  // Color mostW = ColorRgb8(0, 0, 0);

  // for (final pixel in palette) {
  //   if (mostW.r < pixel.r) mostW.r = pixel.r;
  //   if (mostW.g < pixel.g) mostW.g = pixel.g;
  //   if (mostW.b < pixel.b) mostW.b = pixel.b;
  // }

  // print(mostW);

  // for (final pixel in palette) {
  //   pixel.rNormalized = pixel.r / mostW.r;
  //   pixel.gNormalized = pixel.g / mostW.g;
  //   pixel.bNormalized = pixel.b / mostW.b;
  // }

  // var level = (log(palette.length) / log(2)).toInt() - 1;
  // print(level);
  // level = level.clamp(0, 3);
  // print(palette.length);

  // final paletteImg = Image(width: 800, height: 100);
  // for (int i = 0; i < palette.length; i++) {
  //   final color = palette[i];

  //   fillRect(
  //     paletteImg,
  //     x1: i * 50,
  //     y1: 0,
  //     x2: (i + 1) * 50,
  //     y2: 100,
  //     color: color,
  //   );
  //   print(color);
  // }

  // File('palette.png').writeAsBytesSync(encodePng(paletteImg));
  //palette = Compression.defaultPalette[3].toList().cast<Color>();
  // final compression =
  //     Compression.withCustomPalette(level: level, palette: palette);

  // for (int i = 0; i < palette.length; i++) {
  //   final color = compression.palette[i];

  //   fillRect(
  //     paletteImg,
  //     x1: i * 50,
  //     y1: 0,
  //     x2: (i + 1) * 50,
  //     y2: 100,
  //     color: color,
  //   );
  //   print(color);
  // }

  //File('palette.png').writeAsBytesSync(encodePng(paletteImg));

  // var a1 = rgbToOklab(157, 0, 1);
  // var a2 = rgbToOklab(4, 10, 41);

  // color distribution

  var colorDistribution = List.filled(360, 0);
  var lDistribution = List.generate(12, (i) => List.filled(100, 0));
  final colorDistributionImg = Image(width: 360, height: 315);

  // count colors
  for (int x = 0; x < result.width; x++) {
    for (int y = 0; y < result.height; y++) {
      final [_, r, g, b] = result[x][y].to4ByteList();
      var [h, s, l] = rgbToHsl(r, g, b);
      final [L, A, B] = rgbToOklab(r, g, b);
      final [l2, c2, h2] = rgbToOklch(r, g, b);

      // l = l2;
      // h = ((h2 - 30 + 360) % 360) / 360;

      final wtf = sqrt(A * A + B * B);
      if (l > 0.95 || l < 0.05 || wtf < .2) continue;
      // if (l > 0.9 || l < 0.05 || wtf < .2) continue;

      colorDistribution[(h * 360).toInt()]++;

      final hInt = (h * 360).toInt();
      final idx = hInt ~/ 30;
      final lScaled = (l * 100).toInt();
      lDistribution[idx][lScaled]++;

      colorDistributionImg.setPixelRgb(
          (hInt + 30) % 360, 215 + lScaled, r, g, b);
    }
  }

  // draw middle
  var maxH = colorDistribution.reduce(max);
  var maxL = lDistribution.map((e) => e.reduce(max)).reduce(max);
  for (int i = 0; i < colorDistribution.length; i++) {
    final color = hslToRgb(i / 360, 1, 0.5);
    //final color = oklchToRgb(((i + 30 + 360) % 360) / 360, 1, 0.5);
    final value = ((colorDistribution[i] / (maxH + 1)) * 100).toInt();
    final x = (i + 30) % 360;
    drawLine(
      colorDistributionImg,
      x1: x,
      y1: 215 - value,
      x2: x,
      y2: 215,
      color: ColorRgb8(color[0], color[1], color[2]),
    );
    if (x % 60 == 0) {
      drawLine(
        colorDistributionImg,
        x1: x,
        y1: 115,
        x2: x,
        y2: 215 - value,
        color: ColorRgb8(255, 255, 255),
      );
    }
  }

  // analyze hues
  var colorCounts = [
    colorDistribution
        .sublist(330, 360)
        .followedBy(colorDistribution.sublist(0, 30))
        .toList()
  ]
      .followedBy(List.generate(
          5, (i) => colorDistribution.sublist(60 * i + 30, 60 * i + 90)))
      .map((cs) => cs.sum)
      .toList();

  final hThreshold = colorCounts.sum / colorCounts.length / 2;
  print('hThreshold: $hThreshold');

  final dominantCount = (result.height * result.width / 8 > colorCounts.sum)
      ? 0
      : colorCounts.where((cc) => cc > hThreshold).length;

  var (compressionLevel, colorCount) = switch (dominantCount) {
    0 => (0, 0),
    1 => (1, 1),
    2 || 3 => (2, 3),
    4 || 5 || 6 => (3, 6),
    _ => throw StateError('Invalid dominant count'),
  };

  //(compressionLevel, colorCount) = (1, 1);

  List<HueSamplesRange> ranges = switch (compressionLevel) {
    0 => [],
    1 => [
        HueSamplesRange(
            0,
            360,
            colorDistribution,
            List.generate(
                100, (j) => lDistribution.fold(0, (c, ls) => c + ls[j])))
      ],
    2 => (colorCounts[0] + colorCounts[2] + colorCounts[4] >
            colorCounts[1] + colorCounts[3] + colorCounts[5])
        ? [
            HueSamplesRange(
                300,
                60,
                colorDistribution
                    .getRange(300, 360)
                    .followedBy(colorDistribution.getRange(0, 60))
                    .toList(),
                List.generate(
                    100,
                    (j) => [
                          lDistribution[10],
                          lDistribution[11],
                          lDistribution[0],
                          lDistribution[1]
                        ].fold(0, (c, ls) => c + ls[j]))),
            HueSamplesRange(
                60,
                180,
                colorDistribution.getRange(60, 180).toList(),
                List.generate(
                    100,
                    (j) => lDistribution
                        .getRange(2, 6)
                        .fold(0, (c, ls) => c + ls[j]))),
            HueSamplesRange(
                180,
                300,
                colorDistribution.getRange(180, 300).toList(),
                List.generate(
                    100,
                    (j) => lDistribution
                        .getRange(6, 10)
                        .fold(0, (c, ls) => c + ls[j]))),
          ]
        : List.generate(
            3,
            (i) => HueSamplesRange(
                i * 120,
                i * 120 + 120,
                colorDistribution.getRange(i * 120, i * 120 + 120).toList(),
                List.generate(
                    100,
                    (j) => lDistribution
                        .getRange(i * 4, i * 4 + 4)
                        .fold(0, (c, ls) => c + ls[j])))),
    3 => [
        HueSamplesRange(
            330,
            30,
            colorDistribution
                .sublist(330, 360)
                .followedBy(colorDistribution.sublist(0, 30))
                .toList(),
            List.generate(
                100, (j) => lDistribution[0][j] + lDistribution[11][j]))
      ]
          .followedBy(List.generate(
              5,
              (i) => HueSamplesRange(
                  i * 60 + 30,
                  i * 60 + 90,
                  colorDistribution.sublist(i * 60 + 30, i * 60 + 90),
                  List.generate(
                      100,
                      (j) =>
                          lDistribution[i * 2 + 1][j] +
                          lDistribution[i * 2 + 2][j]))))
          .toList(),
    _ => throw StateError('How did you get here?'),
  };

  // opt make ls smooth
  for (int i = 0; i < ranges.length; i++) {
    final ls = ranges[i].ls;
    final newLs = List.filled(100, 0);
    final newLs2 = List.filled(100, 0);
    for (int j = 1; j < ls.length - 1; j++) {
      newLs[j] = (ls[j - 1] + ls[j] + ls[j + 1]) ~/ 3;
    }
    for (int j = 2; j < ls.length - 2; j++) {
      newLs2[j] = (newLs[j - 2] +
              newLs[j - 1] +
              newLs[j] +
              newLs[j + 1] +
              newLs[j + 2]) ~/
          5;
    }
    ranges[i].lsSmooth = newLs2;

    // find lThreshold
    //ranges[i].lThreshold
    var mid = (newLs2.lastIndexWhere((l) => l != 0) +
            newLs2.indexWhere((l) => l != 0)) ~/
        2;

    if (mid == -1) mid = 0;

    int thr = mid;
    final derivs =
        List.generate(100, (i) => i == 99 ? 0 : newLs2[i + 1] - newLs2[i]);

    int mn = 0, mx = 99;

    if (derivs[mid] == 0) {
      int l = mid, r = mid;

      while (l > mn && derivs[l] == 0) l--;
      while (r < mx && derivs[r] == 0) r++;

      if (derivs[l] > 0 && derivs[r] > 0) {
        thr = l;
      } else if (derivs[l] < 0 && derivs[r] < 0) {
        thr = r;
      }
    } else {}
    {
      int border = 0;
      if (derivs[thr] < 0) {
        while (thr < mx && derivs[thr] <= 0) thr++;
        if (thr == mx) {
          thr = mid;
        } else {
          border = thr - 1;
          while (border > mn && derivs[border] == 0) border--;
          thr = (thr + border) ~/ 2;
        }
      } else {
        while (thr > mn && derivs[thr] >= 0) thr--;
        if (thr == mn) {
          thr = mid;
        } else {
          border = thr + 1;
          while (border < mx && derivs[border] == 0) border++;
          thr = (thr + border) ~/ 2;
        }
      }
    }

    ranges[i].lThreshold = thr;
  }

  // draw counts
  for (int i = 0; i < 6; i++) {
    final count = colorCounts[i];
    drawString(
      colorDistributionImg,
      count.toString(),
      font: arial14,
      color: ColorRgb8(255, 255, 255),
      x: i * 60 + 25,
      y: 100,
    );
  }

  for (int i = 0; i < ranges.length; i++) {
    final width = 360 ~/ colorCount;
    final ls = ranges[i].lsSmooth;
    for (int j = 0; j < ls.length; j++) {
      final value = ((ls[j] / (maxL + 1)) * width).toInt();
      final color =
          hslToRgb(((ranges[i].start + width / 2) % 360) / 360, 1, j / 100);
      // final color = oklchToRgb(
      //     ((ranges[i].start + width / 2 + 30) % 360) / 360, 1, j / 100);
      drawLine(
        colorDistributionImg,
        x1: i * width,
        y1: j,
        x2: i * width + value,
        y2: j,
        color: ColorRgb8(color[0], color[1], color[2]),
      );
    }

    final value = ((ls[ranges[i].lThreshold] / maxL) * width).toInt();
    drawLine(colorDistributionImg,
        x1: i * width + value,
        y1: ranges[i].lThreshold,
        x2: i * width + width,
        y2: ranges[i].lThreshold,
        color: ColorRgb8(255, 255, 255));
  }

  final hTolThreshold = List.generate(
      360,
      (i) =>
          ranges
              .firstWhereOrNull((r) => (r.start < r.end)
                  ? r.start <= i && r.end > i
                  : r.start <= i || r.end > i)
              ?.lThreshold ??
          -1);
  final hToValue = List.generate(
      360,
      (i) =>
          1 +
          ranges.indexWhere((r) => (r.start < r.end)
              ? r.start <= i && r.end > i
              : r.start <= i || r.end > i));

  File('colorDistribution.png')
      .writeAsBytesSync(encodePng(colorDistributionImg));

  //final toDecode = unmap(result, compression.palette);
  final toDecode = unmap2(result, compressionLevel, hTolThreshold, hToValue);

  final correctedImage = Image(width: result.width, height: result.height);

  // var numColors = 6;
  // var shift = 0;
  // var hues = List.generate(numColors, (i) => shift + 360 / numColors * i);
  // var nHues = hues.map((h) => h / 360).toList();
  // var hi = 0.7, lo = 0.3, mi = 0.5;

  // var newP = [
  //   hslToRgb(0, 1, 1), // w
  //   hslToRgb(nHues[0], 1, 0.6),
  //   hslToRgb(nHues[1], 1, 0.4),
  //   hslToRgb(nHues[2], 1, mi),
  //   hslToRgb(nHues[3], 1, mi),
  //   hslToRgb(nHues[4], 1, hi),
  //   hslToRgb(nHues[5], 1, 0.6),
  //   //hslToRgb(nHues[6], 1, hi),
  //   hslToRgb(0, 0, 0.75),
  //   hslToRgb(0, 1, 0), // k
  //   hslToRgb(nHues[0], 1, 0.4),
  //   hslToRgb(nHues[1], 1, lo),
  //   hslToRgb(nHues[2], 1, lo),
  //   hslToRgb(nHues[3], 1, lo),
  //   hslToRgb(nHues[4], 1, lo),
  //   hslToRgb(330 / 360, 1, 0.4),
  //   //hslToRgb(nHues[6], 1, lo),
  //   hslToRgb(0, 0, 0.25),
  // ].map((c) => ColorRgb8(c[0], c[1], c[2]) as Color).toList();

  for (int x = 0; x < correctedImage.width; x++) {
    for (int y = 0; y < correctedImage.height; y++) {
      correctedImage.setPixel(
          x, y, Compression.defaultPalette[compressionLevel][toDecode[x][y]]);
    }
  }

  File('6_correctedImage.png').writeAsBytesSync(encodePng(correctedImage));

  final payload =
//'DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMN';
      'A LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOT OF SOOOOOOOOOOOOOOOOOOOOME TEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEXT AND MOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE';

  final aqr = Encoder().encode(
    data: payload,
    meta: AqrMeta(
        compression: Compression(
          level: compressionLevel,
        ),
        mask: Mask(number: 0)),
  );

  final errorImg = Image(
      height: result.height * 2,
      width: result.width * 2,
      backgroundColor: ColorRgb8(255, 255, 255));
  var errCount = 0;
  for (int x = 0; x < result.width; x++) {
    for (int y = 0; y < result.height; y++) {
      if (toDecode[x][y] != aqr.data[x][y]) {
        errCount++;
        errorImg.setPixel(x * 2, y * 2,
            Compression.defaultPalette[compressionLevel][toDecode[x][y]]);
        errorImg.setPixel(x * 2 + 1, y * 2 + 1,
            Compression.defaultPalette[compressionLevel][aqr.data[x][y]]);
      }
    }
  }

  File('7_errorImage.png').writeAsBytesSync(encodePng(errorImg));

  print('Errors: $errCount');

  final trash = Decoder().decodeMatrix(toDecode, aqr.meta.compression);

  print(trash.erasures);
  print(trash.errorsCorrected);
  print(trash.text.length);
  print(trash.text);
}

class HueSamplesRange {
  int start;
  int end;
  List<int> hs;
  List<int> ls;
  List<int> lsSmooth = [];
  int lThreshold = 0;

  HueSamplesRange(this.start, this.end,
      [this.hs = const [], this.ls = const []]);
}
