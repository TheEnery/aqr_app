import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';
import 'package:aqr_lib/decoder.dart';
import 'package:aqr_lib/encoder.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

import '../core/camera_controller_extension.dart';
import '../dummy/loading_widget.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  int _currentCameraIndex = 0;
  bool _enableTorch = false;
  final _scanDelayMs = 2000;
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameras == null) {
      return const LoadingWidget();
    }

    if (_cameras!.isEmpty) {
      return const Center(
        child: Text('There is no available cameras.'),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const LoadingWidget();
    }

    final canToggleCamera = _cameras!.length > 1;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(child: CameraPreview(_controller!)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (canToggleCamera)
                IconButton(
                  onPressed: _toggleCamera,
                  icon: const Icon(Icons.flip_camera_android),
                ),
              IconButton(
                onPressed: _toggleFlashMode,
                icon: Icon(
                  _enableTorch ? Icons.flashlight_on : Icons.flashlight_off,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _initialize() async {
    _cameras = await availableCameras();
    setState(() {});

    if (_cameras!.isEmpty) return;

    _controller = CameraController(
      _cameras![_currentCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
    await _controller!.setFlashMode(FlashMode.off);
    _subscribeToScan();
    setState(() {});
  }

  Stream<(DecoderResult?, DecoderDebugInfo)> _scanning() async* {
    while (true) {
      final result = await Future.delayed(
        Duration(milliseconds: _scanDelayMs),
        () async {
          final stopwatch = Stopwatch()..start();

          final image = await _controller!.inMemoryImage();
          final result = await compute((image) {
            final lrgb = LrgbMatrix.fromImage(image);
            final compare = Encoder().encode(
                data:
                    'A LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOT OF SOOOOOOOOOOOOOOOOOOOOME TEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEXT AND MOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE',
                meta: AqrMeta(
                  compression: Compression(level: 2),
                  mask: Mask(number: 0),
                ));
            final debugInfo = DecoderDebugInfo()..compareWith = compare;

            try {
              return (Decoder().decode(lrgb, debugInfo: debugInfo), debugInfo);
            } on Exception catch (e, s) {
              debugPrintStack(stackTrace: s, label: e.toString());
              print('ERRORS: ${debugInfo.errorCount}');
              return (null, debugInfo);
            }
          }, image, debugLabel: 'AQR scan');

          stopwatch.stop();
          print('scanned for ${stopwatch.elapsedMilliseconds}ms');
          return result;
        },
      );
      yield result;
    }
  }

  void _subscribeToScan() {
    _scanSubscription = _scanning().listen(
      (event) {
        if (!context.mounted) return;
        showModalBottomSheet(
            context: context,
            builder: (context) {
              final debugInfo = event.$2;

              if (event.$1 != null) {
                return Column(
                  children: [
                    Text(event.$1!.text),
                    Text('Error count: ${debugInfo.errorCount}'),
                  ],
                );
              }

              return SingleChildScrollView(
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
                      Image.memory(
                          imglib.encodePng(debugInfo.colorDistributionImage!)),
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
              );
            }).then((_) => _subscribeToScan());
        _unsubscribeToScan();
      },
    );
  }

  void _unsubscribeToScan() {
    _scanSubscription?.cancel();
  }

  void _toggleCamera() async {
    setState(() {
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    });
    await _controller!.setDescription(_cameras![_currentCameraIndex]);
    if (_enableTorch) {
      await _controller!.setFlashMode(FlashMode.off);
      await _controller!.setFlashMode(FlashMode.torch);
    }
  }

  void _toggleFlashMode() async {
    setState(() {
      _enableTorch = !_enableTorch;
    });
    await _controller!
        .setFlashMode(_enableTorch ? FlashMode.torch : FlashMode.off);
  }
}
