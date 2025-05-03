import 'dart:io';

import 'package:image/image.dart' hide Encoder;
import 'package:zxing_lib/src/core/aqr_meta.dart';
import 'package:zxing_lib/src/core/compression.dart';
import 'package:zxing_lib/src/core/mask.dart';
import 'package:zxing_lib/src/encoder/encoder.dart';

import 'daaamn.dart';
import 'hue.dart';

void main() {
  final level = 2;
  // final palette = Compression.defaultPalette[level]
  //     .toList()
  //     .reversed
  //     .toList(); //..sort((c1, c2) => c1.luminance.compareTo(c2.luminance));
  // var newP =
  //     palette.map((c) => [c.r.toInt(), c.g.toInt(), c.b.toInt()]).toList();
  // nudgeLumas(newP);
  // final numColors = newP.length;

  // final w = newP.first;
  // final k = newP.last;
  // final ws = newP.skip(1).take(numColors ~/ 2 - 1).toList()
  //   ..sort((a, b) => rgbToH(a).compareTo(rgbToH(b)));
  // final ks = newP.skip(1 + numColors ~/ 2 - 1).take(numColors ~/ 2 - 1).toList()
  //   ..sort((a, b) => rgbToH(a).compareTo(rgbToH(b)));

  // newP = [w, ...ws, ...ks.reversed, k];

  // final middle = newP.length ~/ 2;
  // newP.setAll(middle, newP.sublist(middle).reversed);

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
  // ];
  final payload = //'DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMN';
      'A LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOT OF SOOOOOOOOOOOOOOOOOOOOME TEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEXT AND MOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE';

  final aqr = Encoder().encode(
    data: payload,
    meta: AqrMeta(
        compression: Compression(
          level: level,
        ),
        mask: Mask(number: 0)),
  );

  final image = copyResize(aqr.draw(), width: 512, height: 512);

  File('image.png').writeAsBytesSync(encodePng(image));

  // final paletteImg = Image(width: 400, height: 100);
  // for (int i = 0; i < newP.length; i++) {
  //   final color = ColorRgb8(newP[i][0], newP[i][1], newP[i][2]);
  //   //final color = ColorRgb8(palette.getRed(i).toInt(),
  //   //    palette.getGreen(i).toInt(), palette.getBlue(i).toInt());
  //   fillRect(
  //     paletteImg,
  //     x1: (i % 8) * 50,
  //     y1: 50 * (i ~/ 8),
  //     x2: ((i % 8) + 1) * 50,
  //     y2: 100,
  //     color: color,
  //   );
  //   print(color);
  // }

  // File('palette.png').writeAsBytesSync(encodePng(paletteImg));
}
