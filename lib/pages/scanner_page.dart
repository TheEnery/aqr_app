import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:aqr_lib/core.dart';
import 'package:aqr_lib/decoder.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/camera_controller_extension.dart';
import '../dummy/loading_widget.dart';
import '../widgets/decoder_debug_log.dart';

import 'scanner_result_page_wrapper.dart';

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
  bool _isDebugEnabled = false;
  bool _isPickingFile = false;
  final _scanDelayMs = 200;
  bool _shouldDebugFails = false;
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MenuAnchor(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.bug_report),
                    child: Text(
                        _isDebugEnabled ? 'Disable debug' : 'Enable debug'),
                    onPressed: () {
                      setState(() => _isDebugEnabled = !_isDebugEnabled);
                    },
                  ),
                  if (_isDebugEnabled)
                    MenuItemButton(
                      leadingIcon: const Icon(Icons.analytics),
                      child: Text(_shouldDebugFails
                          ? 'Debug success only'
                          : 'Debug fails'),
                      onPressed: () {
                        setState(() => _shouldDebugFails = !_shouldDebugFails);
                      },
                    ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.info),
                    child: const Text('About'),
                    onPressed: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'AQR',
                        applicationVersion: 'v0.1.0',
                      );
                    },
                  )
                ],
                builder: (context, controller, child) => IconButton(
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: const Icon(Icons.menu)),
              ),
              Row(
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
            ],
          ),
        ),
        Expanded(
          child: FractionallySizedBox(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: FittedBox(
              clipBehavior: Clip.hardEdge,
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            ),
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

  Stream<(DecoderResult?, DecoderDebugInfo?)> _scanning() async* {
    while (true) {
      final result = await Future.delayed(
        Duration(milliseconds: _scanDelayMs),
        () async {
          final stopwatch = Stopwatch()..start();

          final image = await _controller!.inMemoryImage();

          final result = await compute((params) {
            final (image, isDebugEnabled) = params;
            final lrgb = LrgbMatrix.fromImage(image);
            // final compare = Encoder().encode(
            //     data:
            //         'A LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOT OF SOOOOOOOOOOOOOOOOOOOOME TEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEXT AND MOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE',
            //     meta: AqrMeta(
            //       compression: Compression(level: 2),
            //       mask: Mask(number: 0),
            //     ));
            final debugInfo = isDebugEnabled
                ? DecoderDebugInfo()
                : null; //..compareWith = compare;

            try {
              return (Decoder().decode(lrgb, debugInfo: debugInfo), debugInfo);
            } on Exception catch (e, s) {
              debugPrintStack(stackTrace: s, label: e.toString());
              print('ERRORS: ${debugInfo?.errorCount}');
              return (null, debugInfo);
            }
          }, (image, _isDebugEnabled), debugLabel: 'AQR scan');

          stopwatch.stop();
          print('scanned camera for ${stopwatch.elapsedMilliseconds}ms');
          return result;
        },
      );
      yield result;
    }
  }

  void _subscribeToScan() {
    if (_scanSubscription != null) return;
    _scanSubscription = _scanning().listen(_handleScanningResult);
  }

  void _unsubscribeToScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
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

    final result = await compute((params) {
      final (image, isDebugEnabled) = params;
      final lrgb = LrgbMatrix.fromImage(image);
      // final compare = Encoder().encode(
      //     data:
      //         'A LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOT OF SOOOOOOOOOOOOOOOOOOOOME TEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEXT AND MOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE',
      //     meta: AqrMeta(
      //       compression: Compression(level: 2),
      //       mask: Mask(number: 0),
      //     ));
      final debugInfo =
          isDebugEnabled ? DecoderDebugInfo() : null; //..compareWith = compare;

      try {
        return (Decoder().decode(lrgb, debugInfo: debugInfo), debugInfo);
      } on Exception catch (e, s) {
        debugPrintStack(stackTrace: s, label: e.toString());
        print('ERRORS: ${debugInfo?.errorCount}');
        return (null, debugInfo);
      }
    }, (image, _isDebugEnabled), debugLabel: 'AQR scan');
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

  void _handleScanningResult((DecoderResult?, DecoderDebugInfo?) event) {
    if (!context.mounted) return;
    if (_isPickingFile) return;

    final (result, debugInfo) = (event);
    final haveResult = result != null;
    final showDebugInfo = _isDebugEnabled && (haveResult || _shouldDebugFails);

    if (haveResult) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ScannerResultPageWrapper(result: result);
          },
        ),
      ).then((_) => _subscribeToScan());
      _unsubscribeToScan();
    }

    if (!showDebugInfo) return;

    final future = showModalBottomSheet(
        context: context,
        builder: (context) {
          return DecoderDebugLog(debugInfo: debugInfo!);
        });
    if (!haveResult) future.then((_) => _subscribeToScan());
    _unsubscribeToScan();
  }
}
