import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

class ImageConverter {
  ///
  /// Converts a [CameraImage] to [imglib.Image] in RGB format with rotation correction.
  ///
  static imglib.Image convertCameraImage(
    CameraImage cameraImage, {
    int? rotationDegrees,
  }) {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return convertYUV420ToImage(cameraImage,
          rotationDegrees: rotationDegrees);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return convertBGRA8888ToImage(cameraImage,
          rotationDegrees: rotationDegrees);
    } else {
      throw Exception('Undefined image type.');
    }
  }

  ///
  /// Converts a [CameraImage] in BGRA8888 format to [imglib.Image] in RGB format with rotation correction.
  ///
  static imglib.Image convertBGRA8888ToImage(
    CameraImage cameraImage, {
    int? rotationDegrees,
  }) {
    final width = cameraImage.planes[0].width!;
    final height = cameraImage.planes[0].height!;

    final rotatedWidth =
        (rotationDegrees == 90 || rotationDegrees == 270) ? height : width;
    final rotatedHeight =
        (rotationDegrees == 90 || rotationDegrees == 270) ? width : height;

    final image = imglib.Image(width: rotatedWidth, height: rotatedHeight);

    (int x, int y) Function(int x, int y) getRotatedPosition =
        switch (rotationDegrees) {
      0 => (int x, int y) => (x, y),
      90 => (int x, int y) => (height - 1 - y, x),
      180 => (int x, int y) => (width - 1 - x, height - 1 - y),
      270 => (int x, int y) => (y, width - 1 - x),
      _ => (int x, int y) => (x, y)
    };

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final bgraOffset = (y * width + x) * 4;
        final r = cameraImage.planes[0].bytes[bgraOffset + 2];
        final g = cameraImage.planes[0].bytes[bgraOffset + 1];
        final b = cameraImage.planes[0].bytes[bgraOffset + 0];

        final (newX, newY) = getRotatedPosition(x, y);
        image.setPixelRgb(newX, newY, r, g, b);
      }
    }

    return image;
  }

  ///
  /// Converts a [CameraImage] in YUV420 format to [imglib.Image] in RGB format with rotation correction.
  ///
  static imglib.Image convertYUV420ToImage(
    CameraImage cameraImage, {
    int? rotationDegrees,
  }) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final rotatedWidth =
        (rotationDegrees == 90 || rotationDegrees == 270) ? height : width;
    final rotatedHeight =
        (rotationDegrees == 90 || rotationDegrees == 270) ? width : height;

    final image = imglib.Image(width: rotatedWidth, height: rotatedHeight);

    (int x, int y) Function(int x, int y) getRotatedPosition =
        switch (rotationDegrees) {
      0 => (int x, int y) => (x, y),
      90 => (int x, int y) => (height - 1 - y, x),
      180 => (int x, int y) => (width - 1 - x, height - 1 - y),
      270 => (int x, int y) => (y, width - 1 - x),
      _ => (int x, int y) => (x, y)
    };

    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final yPixelStride = cameraImage.planes[0].bytesPerPixel!;

    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    for (int h = 0; h < height; h++) {
      int uvh = (h / 2).floor();

      for (int w = 0; w < width; w++) {
        int uvw = (w / 2).floor();

        final yIndex = (h * yRowStride) + (w * yPixelStride);
        final int y = yBuffer[yIndex];

        final uvIndex = (uvh * uvRowStride) + (uvw * uvPixelStride);
        final int u = uBuffer[uvIndex];
        final int v = vBuffer[uvIndex];

        int r = (y + v * 1436 / 1024 - 179).round();
        int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
        int b = (y + u * 1814 / 1024 - 227).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        final (newX, newY) = getRotatedPosition(w, h);
        image.setPixelRgb(newX, newY, r, g, b);
      }
    }

    return image;
  }
}
