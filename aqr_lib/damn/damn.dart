import 'dart:io';
import 'dart:math';
import 'dart:math';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';

List<double> yCbCrToLab(double yPrime, double cb, double cr) {
  // Step 1: Convert Y'CbCr to Linear RGB (without gamma correction)
  List<double> linearRgb = yCbCrToLinearRgb(yPrime, cb, cr);

  // Step 2: Convert Linear RGB to XYZ
  List<double> xyz = linearRgbToXyz(linearRgb);

  // Step 3: Convert XYZ to Lab
  List<double> lab = xyzToLab(xyz);

  return lab;
}

// Y'CbCr to Linear RGB (without gamma correction)
List<double> yCbCrToLinearRgb(double yPrime, double cb, double cr) {
  double y = (yPrime) / 255.0;
  double cbNormalized = (cb - 128) / 255.0;
  double crNormalized = (cr - 128) / 255.0;

  double r = y + 1.402 * crNormalized;
  double g = y - 0.344136 * cbNormalized - 0.714136 * crNormalized;
  double b = y + 1.772 * cbNormalized;

  // Apply sRGB to linear RGB transformation
  r = r > 0.04045 ? pow((r + 0.055) / 1.055, 2.4).toDouble() : r / 12.92;
  g = g > 0.04045 ? pow((g + 0.055) / 1.055, 2.4).toDouble() : g / 12.92;
  b = b > 0.04045 ? pow((b + 0.055) / 1.055, 2.4).toDouble() : b / 12.92;

  return [r, g, b];
}

// Linear RGB to XYZ conversion
List<double> linearRgbToXyz(List<double> rgb) {
  // Convert from Linear RGB to XYZ using a transformation matrix
  List<List<double>> rgbToXyzMatrix = [
    [0.4124564, 0.3575761, 0.1804375],
    [0.2126729, 0.7151522, 0.0721750],
    [0.0193339, 0.1191920, 0.9503041]
  ];

  // Matrix multiplication to get XYZ values
  double r = rgb[0], g = rgb[1], b = rgb[2];
  double x = rgbToXyzMatrix[0][0] * r +
      rgbToXyzMatrix[0][1] * g +
      rgbToXyzMatrix[0][2] * b;
  double y = rgbToXyzMatrix[1][0] * r +
      rgbToXyzMatrix[1][1] * g +
      rgbToXyzMatrix[1][2] * b;
  double z = rgbToXyzMatrix[2][0] * r +
      rgbToXyzMatrix[2][1] * g +
      rgbToXyzMatrix[2][2] * b;

  return [x, y, z];
}

// XYZ to Lab conversion
List<double> xyzToLab(List<double> xyz) {
  // Reference white XYZ values (D65)
  double xr = 0.95047, yr = 1.00000, zr = 1.08883;

  double x = xyz[0] / xr;
  double y = xyz[1] / yr;
  double z = xyz[2] / zr;

  // Apply the non-linear transformation (for each channel)
  x = ((x > 0.008856) ? pow(x, 1 / 3) : (x * 903.3 + 16) / 116).toDouble();
  y = ((y > 0.008856) ? pow(y, 1 / 3) : (y * 903.3 + 16) / 116).toDouble();
  z = ((z > 0.008856) ? pow(z, 1 / 3) : (z * 903.3 + 16) / 116).toDouble();

  // Calculate L*, a*, and b*
  double l = (116 * y) - 16;
  double a = 500 * (x - y);
  double b = 200 * (y - z);

  return [l, a, b];
}

double yCbCrToL(double yPrime, double cb, double cr) {
  // Step 1: Y'CbCr to Linear RGB
  double y = yPrime / 255.0;
  double cbNorm = (cb - 128) / 255.0;
  double crNorm = (cr - 128) / 255.0;

  double r = y + 1.402 * crNorm;
  double g = y - 0.344136 * cbNorm - 0.714136 * crNorm;
  double b = y + 1.772 * cbNorm;

  // Apply gamma correction to get linear RGB
  r = r > 0.04045 ? pow((r + 0.055) / 1.055, 2.4).toDouble() : r / 12.92;
  g = g > 0.04045 ? pow((g + 0.055) / 1.055, 2.4).toDouble() : g / 12.92;
  b = b > 0.04045 ? pow((b + 0.055) / 1.055, 2.4).toDouble() : b / 12.92;

  // Step 2: Linear RGB to XYZ
  double yL = 0.2126729 * r + 0.7151522 * g + 0.0721750 * b;

  return yL;

  // Step 3: XYZ to Lab
  //yL = yL > 0.008856 ? pow(yL, 1 / 3).toDouble() : (yL * 903.3 + 16) / 116;

  //return (116 * yL) - 16;
}

void main() {
  // Generate random YCbCr pixels
  final random = Random();
  final pixels = List.generate(
      10000,
      (_) => {
            'Y': random.nextDouble() * 255,
            'Cb': random.nextDouble() * 255,
            'Cr': random.nextDouble() * 255,
          });

  // Sort by Y and create an image
  final sortedByY = List.of(pixels)..sort((a, b) => a['Y']!.compareTo(b['Y']!));
  final imageByY = createImageFromPixels(sortedByY);
  File('sorted_by_Y.png').writeAsBytesSync(encodePng(imageByY));

  // Sort by Y and create an image
  final sortedByYLinear = sortedByY.map(
    (e) {
      //final Yl = pow(e['Y']! / 255, 1 / 2.2).toDouble();
      //final res = Yl <= 0.008856 ? Yl * 903.3 : pow(Yl, 1 / 3) * 116 - 16;
      final res = yCbCrToL(e['Y']!, e['Cb']!, e['Cr']!);
      return e..addAll({'Yl': res});
    },
  ).toList()
    ..sort((a, b) => a['Yl']!.compareTo(b['Yl']!));
  final imageByYLinear = createImageFromPixels(sortedByYLinear);
  File('sorted_by_YLinear.png').writeAsBytesSync(encodePng(imageByYLinear));

  // Convert YCbCr to Lab and calculate L component
  final pixelsWithLab = sortedByY.map((pixel) {
    final rgb = yCbCrToRgb(pixel['Y']!, pixel['Cb']!, pixel['Cr']!);
    final lab = rgbToLab(rgb['r']!, rgb['g']!, rgb['b']!);
    return {
      'L': lab['L']!,
      'r': rgb['r']!,
      'g': rgb['g']!,
      'b': rgb['b']!,
    };
  }).toList();

  // Sort by L and create an image
  final sortedByL = List.of(pixelsWithLab)
    ..sort((a, b) => a['L']!.compareTo(b['L']!));
  final imageByL = createImageFromPixels(sortedByL, isLab: true);
  File('sorted_by_L.png').writeAsBytesSync(encodePng(imageByL));

  ///////////////////

  var rgbList = List.generate(10000,
      (i) => [random.nextInt(255), random.nextInt(255), random.nextInt(255)]);
  rgbList.sort((l1, l2) => getL(l1).compareTo(getL(l2)));
  final rgbImage = Image(width: 100, height: 100);
  for (int x = 0; x < 100; x++) {
    for (int y = 0; y < 100; y++) {
      final p = rgbList[x + y * 100];
      rgbImage.setPixelRgb(x, y, p[0], p[1], p[2]);
    }
  }
  File('sorted_by_Lrgb.png').writeAsBytesSync(encodePng(rgbImage));

  rgbList.forEach((l) => applyGamma(l, 1 / 2.4));
  final gammaRgbImageEn = Image(width: 100, height: 100);
  for (int x = 0; x < 100; x++) {
    for (int y = 0; y < 100; y++) {
      final p = rgbList[x + y * 100];
      gammaRgbImageEn.setPixelRgb(x, y, p[0], p[1], p[2]);
    }
  }
  File('sorted_by_LrgbGammaEn.png')
      .writeAsBytesSync(encodePng(gammaRgbImageEn));

  rgbList.forEach((l) => applyGamma(l, 2.4));
  rgbList.forEach((l) => applyGamma(l, 2.4));
  final gammaRgbImageDe = Image(width: 100, height: 100);
  for (int x = 0; x < 100; x++) {
    for (int y = 0; y < 100; y++) {
      final p = rgbList[x + y * 100];
      gammaRgbImageDe.setPixelRgb(x, y, p[0], p[1], p[2]);
    }
  }
  File('sorted_by_LrgbGammaDe.png')
      .writeAsBytesSync(encodePng(gammaRgbImageDe));

  rgbList.sort((l1, l2) => getL(l1).compareTo(getL(l2)));
  rgbList.forEach((l) => applyGamma(l, 1 / 2.4));
  final gammaRgbImageDe2 = Image(width: 100, height: 100);
  for (int x = 0; x < 100; x++) {
    for (int y = 0; y < 100; y++) {
      final p = rgbList[x + y * 100];
      gammaRgbImageDe2.setPixelRgb(x, y, p[0], p[1], p[2]);
    }
  }
  File('sorted_by_LrgbGammaDe2.png')
      .writeAsBytesSync(encodePng(gammaRgbImageDe2));
}

double getL(List<int> l) {
  return 0.2126729 * l[0] + 0.7151522 * l[1] + 0.0721750 * l[2];
}

void applyGamma(List<int> l, double gamma) {
  l[0] = (pow(l[0] / 255, gamma).clamp(0, 1) * 255).toInt();
  l[1] = (pow(l[1] / 255, gamma).clamp(0, 1) * 255).toInt();
  l[2] = (pow(l[2] / 255, gamma).clamp(0, 1) * 255).toInt();
}

Image createImageFromPixels(List<Map<String, double>> pixels,
    {bool isLab = false}) {
  final size = sqrt(pixels.length).toInt();
  final image = Image(width: size, height: size);
  for (int i = 0; i < pixels.length; i++) {
    final x = i % size;
    final y = i ~/ size;
    if (isLab) {
      image.setPixelRgb(x, y, pixels[i]['r']!.toInt(), pixels[i]['g']!.toInt(),
          pixels[i]['b']!.toInt());
    } else {
      final rgb =
          yCbCrToRgb(pixels[i]['Y']!, pixels[i]['Cb']!, pixels[i]['Cr']!);
      image.setPixelRgb(
          x, y, rgb['r']!.toInt(), rgb['g']!.toInt(), rgb['b']!.toInt());
    }
  }
  return image;
}

Map<String, double> yCbCrToRgb(double y, double cb, double cr) {
  final r = (y + 1.402 * (cr - 128)).clamp(0, 255);
  final g = (y - 0.344136 * (cb - 128) - 0.714136 * (cr - 128)).clamp(0, 255);
  final b = (y + 1.772 * (cb - 128)).clamp(0, 255);
  return {'r': r.toDouble(), 'g': g.toDouble(), 'b': b.toDouble()};
}

Map<String, double> rgbToLab(double r, double g, double b) {
  // Normalize RGB to [0, 1]
  r /= 255;
  g /= 255;
  b /= 255;

  // Apply sRGB to linear RGB transformation
  r = r > 0.04045 ? pow((r + 0.055) / 1.055, 2.4).toDouble() : r / 12.92;
  g = g > 0.04045 ? pow((g + 0.055) / 1.055, 2.4).toDouble() : g / 12.92;
  b = b > 0.04045 ? pow((b + 0.055) / 1.055, 2.4).toDouble() : b / 12.92;

  // Convert to XYZ
  final x = (r * 0.4124564 + g * 0.3575761 + b * 0.1804375) / 0.95047;
  final y = (r * 0.2126729 + g * 0.7151522 + b * 0.0721750) / 1.00000;
  final z = (r * 0.0193339 + g * 0.1191920 + b * 0.9503041) / 1.08883;

  // Convert to Lab
  final fx = x > 0.008856 ? pow(x, 1 / 3).toDouble() : (7.787 * x) + 16 / 116;
  final fy = y > 0.008856 ? pow(y, 1 / 3).toDouble() : (7.787 * y) + 16 / 116;
  final fz = z > 0.008856 ? pow(z, 1 / 3).toDouble() : (7.787 * z) + 16 / 116;

  final l = (116 * fy) - 16;
  final a = 500 * (fx - fy);
  final bVal = 200 * (fy - fz);
  return {'L': l, 'a': a, 'b': bVal};
}
