import 'package:flutter/material.dart';

import 'package:aqr_lib/decoder.dart';
import 'package:image/image.dart' as imglib;

class DecoderDebugLog extends StatelessWidget {
  const DecoderDebugLog({
    super.key,
    required this.debugInfo,
  });

  final DecoderDebugInfo debugInfo;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1.0,
      heightFactor: 1.0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (debugInfo.wbImage != null) ...[
              const Text('Black and white image:'),
              Image.memory(imglib.encodePng(debugInfo.wbImage!)),
            ],
            if (debugInfo.wbDetectedImage != null) ...[
              const Text('Black and white detected image:'),
              Image.memory(
                imglib.encodePng(imglib.copyResize(
                  debugInfo.wbDetectedImage!,
                  height: 500,
                  width: 500,
                )),
                fit: BoxFit.fitWidth,
              ),
            ],
            if (debugInfo.detectedImage != null) ...[
              const Text('Detected image:'),
              Image.memory(imglib.encodePng(imglib.copyResize(
                debugInfo.detectedImage!,
                height: 500,
                width: 500,
              ))),
            ],
            if (debugInfo.colorCorrectedImage != null) ...[
              const Text('Color corrected image:'),
              Image.memory(imglib.encodePng(imglib.copyResize(
                debugInfo.colorCorrectedImage!,
                height: 500,
                width: 500,
              ))),
            ],
            if (debugInfo.colorDistributionImage != null) ...[
              const Text('Color distribution:'),
              Image.memory(imglib.encodePng(debugInfo.colorDistributionImage!)),
            ],
            if (debugInfo.correctedImage != null) ...[
              const Text('Corrected image:'),
              Image.memory(imglib.encodePng(imglib.copyResize(
                debugInfo.correctedImage!,
                height: 500,
                width: 500,
              ))),
            ],
            if (debugInfo.errorImage != null) ...[
              const Text('Error image:'),
              Image.memory(imglib.encodePng(imglib.copyResize(
                debugInfo.errorImage!,
                height: 500,
                width: 500,
              ))),
            ],
            Text('Error count: ${debugInfo.errorCount}'),
          ],
        ),
      ),
    );
  }
}
