import 'dart:typed_data';

import 'package:image/image.dart' hide Encoder;

import 'src/binarizer/hybrid_binarizer.dart';
import 'src/qrcode/encode_hint.dart';
import 'src/decoder/error_correction_level.dart';
import 'src/qrcode/qrcode_reader.dart';
import 'src/qrcode/qrcode_writer.dart';
import 'src/result.dart';
import 'src/rgb_luminance_source.dart';

export 'src/result.dart';
export 'src/decoder/error_correction_level.dart';

class QrCode {
  Result decode(Image image) {
    final buffer = image.toUint8List();
    final luminances = Uint8List(image.width * image.height);
    for (int i = 0; i < luminances.length; i++) {
      final r = buffer[3 * i] & 0xff;
      final g2 = (buffer[3 * i + 1] << 1) & 0x1fe;
      final b = buffer[3 * i + 2];
      luminances[i] = ((r + g2 + b) ~/ 4);
    }
    final luminanceSource = RGBLuminanceSource.orig(
      image.width,
      image.height,
      luminances,
    );
    final matrix = HybridBinarizer(luminanceSource).blackMatrix;
    final reader = QRCodeReader();

    return reader.decode(matrix);
  }

  Image encode(
    String data, [
    ErrorCorrectionLevel ecl = ErrorCorrectionLevel.L,
    int width = 500,
    int height = 500,
  ]) {
    final qr = QRCodeWriter()
        .encode(data, width, height, EncodeHint(errorCorrectionLevel: ecl));
    final image = Image(width: qr.width, height: qr.height);
    final dark = ColorRgb8(0, 0, 0);
    final white = ColorRgb8(255, 255, 255);

    for (int x = 0; x < qr.width; x++) {
      for (int y = 0; y < qr.height; y++) {
        image.setPixel(x, y, qr.get(x, y) ? dark : white);
      }
    }
    return image;
  }
}
