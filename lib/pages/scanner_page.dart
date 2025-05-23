import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';
import 'package:aqr_lib/decoder.dart';
import 'package:aqr_lib/encoder.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:aqr_app/dummy/vertical_gap.dart';

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
  bool _isPickingFile = false;
  final _scanDelayMs = 200;
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    _initialize();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel().then((_) {
      _controller?.dispose();
    });
    WakelockPlus.disable();

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
              IconButton(
                onPressed: _scanImage,
                icon: const Icon(Icons.image),
              ),
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
          print('scanned camera for ${stopwatch.elapsedMilliseconds}ms');
          return result;
        },
      );
      yield result;
    }
  }

  void _subscribeToScan() {
    _scanSubscription = _scanning().listen(_handleScanningResult);
  }

  void _unsubscribeToScan() {
    _scanSubscription?.cancel();
  }

  void _scanImage() async {
    _isPickingFile = true;

    _unsubscribeToScan();

    final pickResult =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (pickResult == null || pickResult.paths.single == null) {
      return;
    }

    final image = await imglib.decodeImageFile(pickResult.paths.single!);

    if (image == null) {
      return;
    }
    final stopwatch = Stopwatch()..start();

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
    print('scanned file for ${stopwatch.elapsedMilliseconds}ms');

    _subscribeToScan();

    _isPickingFile = false;

    _handleScanningResult(result);
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

  void _handleScanningResult((DecoderResult?, DecoderDebugInfo) event) {
    if (!context.mounted) return;
    if (_isPickingFile) return;

    final (result, debugInfo) = (event);

    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(result.text),
                    const VerticalGap(16.0),
                    Text('Error count: ${debugInfo.errorCount}')
                  ],
                ),
              ),
            );
          },
        ),
      ).then((_) => _subscribeToScan());
      _unsubscribeToScan();
      return;
    }

    showModalBottomSheet(
        context: context,
        builder: (context) {
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
            ),
          );
        }).then((_) => _subscribeToScan());
    _unsubscribeToScan();
  }
}
