import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zxing_lib/src/core/lrgb_matrix.dart';
import 'package:zxing_lib/src/decoder/decoder.dart';
import 'package:zxing_lib/src/decoder/decoder_result.dart';

import '../core/camera_controller_extension.dart';
import '../core/image_converter.dart';
import '../widgets/loading_widget.dart';

//import 'file:/home/enery/Documents/aqr/aqr_app/aqr_lib/old_lib/aqr_core.dart';

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
  //Result? _result;
  DecoderResult? _result;
  final _scanDelayMs = 0;
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
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _controller!.initialize();
    await _controller!.setFlashMode(FlashMode.off);
    _subscribeToScan();
    setState(() {});
  }

  Stream _scanning() async* {
    while (true) {
      await Future.delayed(
        Duration(milliseconds: _scanDelayMs),
        () async {
          final image = await _controller!.inMemoryImage();

          _result = await compute(
            (params) {
              //Result? result;
              DecoderResult? result;
              try {
                // final image = ImageConverter.convertCameraImage(params.image);
                // result = QrCode().decode(image);
                result =
                    Decoder().decode(LrgbMatrix.fromCameraImage(params.image));
              } on Exception catch (e, s) {
                debugPrintStack(stackTrace: s, label: e.toString());
              } on Error catch (e, s) {
                debugPrintStack(stackTrace: s, label: 'Daaamn ${e.toString()}');
              }
              return result;
            },
            _ComputationInput(
              image: image,
            ),
          );
        },
      );
      yield null;
    }
  }

  void _subscribeToScan() {
    _scanSubscription = _scanning().listen(
      (event) {
        final context = this.context;
        if (!context.mounted) return;
        ScaffoldMessenger.maybeOf(context)
          ?..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Column(
                children: [
                  Text(_result?.text ?? 'No content'),
                ],
              ),
            ),
          );
      },
    );
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

class _ComputationInput {
  final CameraImage image;

  const _ComputationInput({
    required this.image,
  });
}
