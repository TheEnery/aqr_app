import '../decoder/error_correction_level.dart';

/// These are a set of hints that you may pass to Writers to specify their behavior.
class EncodeHint {
  const EncodeHint({
    this.errorCorrectionLevel,
    this.characterSet,
    this.margin,
    this.qrVersion,
    this.qrMaskPattern,
    this.qrCompact = false,
    this.gs1Format = false,
  });

  /// Specifies what degree of error correction to use, for example in QR Codes.
  /// Type depends on the encoder. For example for QR codes it's type [ErrorCorrectionLevel].
  /// In all cases, it can also be a [String] representation of the desired value as well.
  /// for qrcode
  final ErrorCorrectionLevel? errorCorrectionLevel;

  /// Specifies what character encoding to use where applicable (type [String])
  final String? characterSet;

  /// Specifies margin, in pixels, to use when generating the barcode. The meaning can vary
  /// by format; for example it controls margin before and after the barcode horizontally for
  /// most 1D formats. (Type [Integer], or [String] representation of the integer value).
  final int? margin;

  /// Specifies the exact version of QR code to be encoded.
  /// (Type [Integer], or [String] representation of the integer value).
  final int? qrVersion;

  /// Specifies the QR code mask pattern to be used. Allowed values are
  /// 0..QRCode.NUM_MASK_PATTERNS-1. By default the code will automatically select
  /// the optimal mask pattern.
  /// (Type [Integer], or [String] representation of the integer value).
  final int? qrMaskPattern;

  /// Specifies whether to use compact mode for QR code (type [bool], or "true" or "false" [String] value)
  /// Please note that when compaction is performed, the most compact character encoding is chosen
  /// for characters in the input that are not in the ISO-8859-1 character set. Based on experience,
  /// some scanners do not support encodings like cp-1256 (Arabic). In such cases the encoding can
  /// be forced to UTF-8 by means of the [Encoding] encoding hint.
  final bool qrCompact;

  /// Specifies whether the data should be encoded to the GS1 standard (type [bool],
  /// or "true" or "false" [String] value).
  final bool gs1Format;
}
