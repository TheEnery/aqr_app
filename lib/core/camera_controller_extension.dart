import 'dart:async';

import 'package:camera/camera.dart';

extension CameraControllerExtension on CameraController {
  Future<CameraImage> inMemoryImage() async {
    final completer = Completer<CameraImage>();
    await startImageStream(completer.complete);
    final image = await completer.future;
    await stopImageStream();
    return image;
  }
}
