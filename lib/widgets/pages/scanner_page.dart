import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

import 'package:aqr/core/camera_controller_extension.dart';
import 'package:aqr/widgets/dummy/loading_widget.dart';

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
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _controller!.initialize();
    await _controller!.setFlashMode(FlashMode.off);
    _subscribeToScan();
    setState(() {});
  }

  Stream<imglib.Image> _scanning() async* {
    while (true) {
      final result = await Future.delayed(
        Duration(milliseconds: _scanDelayMs),
        () async {
          final image = await _controller!.inMemoryImage();
          final result = await compute((image) {
            return image;
          }, image);
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
        // showDialog(
        //   context: context,
        //   builder: (context) {
        //     return Image.memory(imglib.encodeBmp(event));
        //   },
        // );
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
