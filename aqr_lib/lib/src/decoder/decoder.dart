/*
 * Copyright 2007 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:typed_data';

import 'package:zxing_lib/src/core/bit_writer.dart';
import 'package:zxing_lib/src/core/compression.dart';
import 'package:zxing_lib/src/core/dec_block_pair.dart';
import 'package:zxing_lib/src/core/lrgb_matrix.dart';
import 'package:zxing_lib/src/decolorizer/decolorizer.dart';
import 'package:zxing_lib/src/detector/detector.dart';
import 'package:zxing_lib/src/detector/global_histogram_binarizer.dart';

import '../core/byte_matrix.dart';
import '../exceptions/checksum_exception.dart';
import '../exceptions/formats_exception.dart';
import '../exceptions/reed_solomon_exception.dart';
import '../reedsolomon/generic_gf.dart';
import '../reedsolomon/reed_solomon_decoder.dart';

import 'bit_matrix_parser.dart';
import 'decoded_bit_stream_parser.dart';
import 'decoder_result.dart';

/// The main class which implements QR Code decoding -- as opposed to locating and extracting
/// the QR Code from an image.
///
/// @author Sean Owen
class Decoder {
  static final ReedSolomonDecoder _rsDecoder =
      ReedSolomonDecoder(GenericGF.qrCodeField256);

  DecoderResult decode(LrgbMatrix image) {
    GlobalHistogramBinarizer(image).blackMatrix;
    final detected = Detector(image).detect().bits;
    final decolorizer = Decolorizer();
    decolorizer.decolorize(detected);
    final compression = decolorizer.compression;
    final decolorized = decolorizer.matrix;
    return decodeMatrix(decolorized, compression);
  }

  DecoderResult decodeMatrix(ByteMatrix bits, Compression compression) {
    final parser = BitMatrixParser(bits);
    parser.compression = compression;
    FormatsException? fe;
    ChecksumException? ce;
    try {
      return _decodeParser(parser, compression);
    } on FormatsException catch (e) {
      fe = e;
    } on ChecksumException catch (e) {
      ce = e;
    }

    try {
      // Revert the bit matrix
      parser.remask();

      // Will be attempting a mirrored reading of the version and format info.
      parser.setMirror(true);

      // Preemptively read the version.
      parser.readVersion();

      // Preemptively read the format information.
      parser.readFormatInformation();

      /*
       * Since we're here, this means we have successfully detected some kind
       * of version and format information when mirrored. This is a good sign,
       * that the QR code may be mirrored, and we should try once more with a
       * mirrored content.
       */
      // Prepare for a mirrored reading.
      parser.mirror();

      final result = _decodeParser(parser, compression);

      // Success! Notify the caller that the code was mirrored.

      return result;
    } on ChecksumException catch (_) {
      // Throw the exception from the original reading
      if (fe != null) {
        throw fe;
      }
      throw ce!; // If fe is null, this can't be
    } on FormatsException catch (_) {
      // Throw the exception from the original reading
      if (fe != null) {
        throw fe;
      }
      throw ce!; // If fe is null, this can't be
    }
  }

  DecoderResult _decodeParser(BitMatrixParser parser, Compression compression) {
    final version = parser.readVersion();
    final ecLevel = parser.readFormatInformation().errorCorrection;

    // Read codewords
    final codewords = parser.readCodewords();
    final data = codewords.data;
    final blocks = <DecBlockPair>[];
    final ecbGroup = version.ecbGroup;
    var maxDataByteCount = 0;

    for (final ecb in ecbGroup.ecBlocks) {
      final dSize = ecb.dCodewordsPerBlock;
      if (maxDataByteCount < dSize) maxDataByteCount = dSize;

      for (int i = 0; i < ecb.repeatCount; i++) {
        blocks.add(
          DecBlockPair(
            Uint8List(dSize),
            Uint8List(ecbGroup.ecCodewordsPerBlock),
          ),
        );
      }
    }

    var index = 0;

    // First, place data blocks.
    for (int i = 0; i < maxDataByteCount; i++) {
      for (final block in blocks) {
        final dataBytes = block.dataCodewords;
        if (i < dataBytes.length) {
          dataBytes[i] = data[index++];
        }
      }
    }

    // Then, place error correction blocks.
    for (int i = 0; i < ecbGroup.ecCodewordsPerBlock; i++) {
      for (final block in blocks) {
        block.errorCorrectionCodewords[i] = data[index++];
      }
    }

    final dataBytes = Uint8List(ecbGroup.dCodewordCount);
    var dataBytesOffset = 0;
    var errorsCorrected = 0;

    for (final block in blocks) {
      errorsCorrected += _correctErrors(block);
      dataBytes.setAll(dataBytesOffset, block.dataCodewords);
      dataBytesOffset += block.dCodewordCount;
    }

    final resultBytes = BitWriter.from(dataBytes);

    return DecodedBitStreamParser.decode(
        resultBytes.reader, version, ecLevel, compression)
      ..errorsCorrected = errorsCorrected;
  }

  /// Given data and error-correction codewords received,
  /// possibly corrupted by errors, attempts to
  /// correct the errors in-place using Reed-Solomon error correction.
  int _correctErrors(DecBlockPair blockPair) {
    final decBytes = blockPair.dataCodewords
        .followedBy(blockPair.errorCorrectionCodewords)
        .toList();
    int errorsCorrected = 0;
    try {
      errorsCorrected = _rsDecoder.decodeWithEcCount(
        decBytes,
        blockPair.ecCodewordCount,
      );
    } on ReedSolomonException catch (_) {
      throw ChecksumException();
    }
    // Copy back into array of bytes -- only need to worry about the bytes that were data
    // We don't care about errors in the error-correction codewords
    for (int i = 0; i < blockPair.dCodewordCount; i++) {
      blockPair.dataCodewords[i] = decBytes[i];
    }

    return errorsCorrected;
  }
}
