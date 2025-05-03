import 'dart:io';

import 'package:image/image.dart';
import 'package:zxing_lib/src/core/aqr_code.dart';
import 'package:zxing_lib/src/core/aqr_meta.dart';
import 'package:zxing_lib/src/core/compression.dart';
import 'package:zxing_lib/src/encoder/encoder.dart';

import 'again.dart';
import 'dadamn.dart';
import 'hue.dart';

void main() {
  int numColors = 4;

  final image = decodePng(File('image.png').readAsBytesSync());

  // final wbimage = Image.from(image!);

  // Color mostW = ColorRgb8(0, 0, 0);

  // for (final pixel in wbimage) {
  //   if (mostW.r < pixel.r) mostW.r = pixel.r;
  //   if (mostW.g < pixel.g) mostW.g = pixel.g;
  //   if (mostW.b < pixel.b) mostW.b = pixel.b;
  // }

  // print(mostW);

  // for (final pixel in wbimage) {
  //   pixel.rNormalized = pixel.r / mostW.r;
  //   pixel.gNormalized = pixel.g / mostW.g;
  //   pixel.bNormalized = pixel.b / mostW.b;
  // }

  //File('wbimage.png').writeAsBytes(encodePng(wbimage));

  //OctreeQuantizer octree = OctreeQuantizer(image!, numberOfColors: 4);
  //final palette = octree.palette;

  //List<List<int>> peaks = extractHistogramPeaks(image!, numColors);

  // double threshold = 0.01; // Change this value to set your count threshold
  // List<List<int>> peaks = extractDominantColors(
  //   image!.getBytes(),
  //   image.width,
  //   image.height,
  //   threshold,
  //   lsbReduction: 4,
  // );

  // double threshold = 0.001; // Change this value to set your count threshold
  // List<List<int>> peaks = extractDominantColorsByHue(
  //   image!,
  //   lsbReduction: 4,
  //   threshold: threshold,
  //   hueThreshold: 15.0,
  // );

  List<List<int>> peaks = extractDistinctColorsZigzag(image!,
      minOccurrence: 5, distanceThreshold: 60);

  numColors = peaks.length;

  peaks.sort((c1, c2) => rgbtoc(c2).luminance.compareTo(rgbtoc(c1).luminance));

  final w = peaks.first;
  final k = peaks.last;
  final ws = peaks.skip(1).take(numColors ~/ 2 - 1).toList()
    ..sort((a, b) => rgbToH(a).compareTo(rgbToH(b)));
  final ks = peaks
      .skip(1 + numColors ~/ 2 - 1)
      .take(numColors ~/ 2 - 1)
      .toList()
    ..sort((a, b) => rgbToH(a).compareTo(rgbToH(b)));

  peaks = [w, ...ws, ...ks.reversed, k];

  //nudgeLumas(peaks);

  //peaks = peaks.reversed.toList();
  final middle = numColors ~/ 2;
  peaks.setAll(middle, peaks.sublist(middle).reversed);

  peaks.map((c) => (c, rgbtoc(c).luminance.round())).forEach(print);

  final paletteImg = Image(width: 800, height: 100);
  for (int i = 0; i < numColors; i++) {
    final color = ColorRgb8(peaks[i][0], peaks[i][1], peaks[i][2]);
    //final color = ColorRgb8(palette.getRed(i).toInt(),
    //    palette.getGreen(i).toInt(), palette.getBlue(i).toInt());
    fillRect(
      paletteImg,
      x1: i * 50,
      y1: 0,
      x2: (i + 1) * 50,
      y2: 100,
      color: color,
    );
    print(color);
  }

  File('palette.png').writeAsBytesSync(encodePng(paletteImg));
}

Color rgbtoc(List<int> rgb) => ColorRgb8(rgb[0], rgb[1], rgb[2]);

nudgeLumas(List<List<int>> colors) {
  final length = colors.length;
  //final step = 256 ~/ length;
  // final lumas =
  //     List.generate(length, (i) => i > length ~/ 2 ? 96 : 160); //i * step);
  // lumas[length ~/ 2 - 1] -= step;
  // lumas[length ~/ 2] += step;

  for (var i = 0; i < length; i++) {
    // var dir = (lumas[i] - rgbtoc(colors[i]).luminance.round()).sign;
    // for (int j = 0; lumas[i] != rgbtoc(colors[i]).luminance.round(); j++) {
    //   var val = colors[i][j % 3];
    //   val += dir;
    //   colors[i][j % 3] = val.clamp(0, 255).toInt();
    // }

    if (i < length ~/ 2) {
      for (int j = 0; 160 > rgbtoc(colors[i]).luminance.round(); j++) {
        var val = colors[i][j % 3];
        val += 1;
        colors[i][j % 3] = val.clamp(0, 255).toInt();
      }
    } else {
      for (int j = 0; 96 < rgbtoc(colors[i]).luminance.round(); j++) {
        var val = colors[i][j % 3];
        val += -1;
        colors[i][j % 3] = val.clamp(0, 255).toInt();
      }
    }
  }
}
