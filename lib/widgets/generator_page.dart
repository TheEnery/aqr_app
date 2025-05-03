import 'package:flutter/material.dart';

import 'package:image/image.dart' as imglib;
import 'package:zxing_lib/src/core/aqr_meta.dart';
import 'package:zxing_lib/src/core/compression.dart';
import 'package:zxing_lib/src/core/error_correction.dart';
import 'package:zxing_lib/src/core/mask.dart';
import 'package:zxing_lib/src/encoder/encoder.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          leading: const Icon(Icons.onetwothree),
          title: const Text('Numbers'),
          onTap: () {
            // create numeric qr
          },
        ),
        ListTile(
          leading: const Icon(Icons.abc),
          title: const Text('Text'),
          onTap: () {
            List<imglib.Image> images = [];

            final aqr = Encoder().encode(
                data: 'dddddddddddddddddddddddddddddd',
                meta: AqrMeta(
                  compression:
                      Compression.withCustomPalette(level: 1, palette: [
                    imglib.ColorRgb8(225, 250, 200),
                    imglib.ColorRgb8(0, 0, 0),
                    imglib.ColorRgb8(75, 45, 175),
                    imglib.ColorRgb8(0, 70, 15)
                  ]),
                  errorCorrection: ErrorCorrection.M,
                ));

            final printed = aqr.draw();

            final image = imglib.copyResize(printed, width: 500, height: 500);

            images.add(image);

            var s = 'd';
            for (int i = 0; i < 500; i++) {
              s += 'd';
            }

            for (int i = 0; i < 8; i++) {
              // create text qr
              final aqr = Encoder().encode(
                  data: s,
                  meta: AqrMeta(
                      compression: Compression(level: 3),
                      errorCorrection: ErrorCorrection.M,
                      mask: Mask(number: i)));

              final printed = aqr.draw();

              final image = imglib.copyResize(printed, width: 500, height: 500);

              images.add(image);
            }

            showDialog(
              context: context,
              builder: (context) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ...images.map((image) => Image.memory(
                            imglib.encodeBmp(image),
                            fit: BoxFit.fitWidth,
                          ))
                    ],
                  ),
                );
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.file_present),
          title: const Text('File'),
          onTap: () {
            // create file qr
          },
        ),
        ListTile(
          leading: const Icon(Icons.brush),
          title: const Text('Kanji/Kana'),
          onTap: () {
            // create kanji/kana qr
          },
        ),
      ],
    );
  }
}
