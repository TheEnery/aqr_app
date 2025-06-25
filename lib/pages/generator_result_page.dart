import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:share_plus/share_plus.dart';

import 'package:aqr_app/dummy/outlined_text_with_label.dart';
import 'package:aqr_app/dummy/vertical_gap.dart';

class GeneratorResultPage extends StatelessWidget {
  final String title;
  final AqrCode aqr;
  final String raw;

  const GeneratorResultPage({
    super.key,
    required this.title,
    required this.aqr,
    required this.raw,
  });

  @override
  Widget build(BuildContext context) {
    final image = aqr.draw();
    final bytes =
        imglib.encodePng(imglib.copyResize(image, width: 500, height: 500));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await FilePicker.platform.saveFile(
                  fileName: 'aqr.png',
                  allowedExtensions: ['png'],
                  bytes: bytes);
            },
            icon: const Icon(Icons.save_alt),
          ),
          IconButton(
            onPressed: () async {
              await SharePlus.instance.share(ShareParams(
                  files: [XFile.fromData(bytes)],
                  fileNameOverrides: ['aqr.png']));
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.memory(bytes),
              const VerticalGap(),
              const Divider(),
              const VerticalGap(),
              OutlinedTextWithLabel(
                text: raw,
                label: 'Raw text',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
