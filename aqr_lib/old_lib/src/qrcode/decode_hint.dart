/// Encapsulates a type of hint that a caller may pass to a barcode reader to help it
/// more quickly or accurately decode it. It is up to implementations to decide what,
/// if anything, to do with the information that is supplied.
class DecodeHint {
  const DecodeHint({
    this.pureBarcode = false,
    this.tryHarder = false,
    this.characterSet,
    this.assumeGs1 = false,
    this.alsoInverted = false,
  });

  /// Image is a pure monochrome image of a barcode. Doesn't matter what it maps to;
  /// use [bool]`true`.
  final bool pureBarcode;

  /// Spend more time to try to find a barcode; optimize for accuracy, not speed.
  /// Doesn't matter what it maps to; use [bool]`true`.
  final bool tryHarder;

  /// Specifies what character encoding to use when decoding, where applicable (type String)
  final String? characterSet;

  /// Assume the barcode is being processed as a GS1 barcode, and modify behavior as needed.
  /// For example this affects FNC1 handling for Code 128 (aka GS1-128). Doesn't matter what it maps to;
  /// use [bool]`true`.
  final bool assumeGs1;

  /// If true, also tries to decode as inverted image. All configured decoders are simply called a
  /// second time with an inverted image. Doesn't matter what it maps to; use [bool]`true`.
  final bool alsoInverted;

  DecodeHint withoutCallback() {
    return DecodeHint(
      pureBarcode: pureBarcode,
      tryHarder: tryHarder,
      characterSet: characterSet,
      assumeGs1: assumeGs1,
      alsoInverted: alsoInverted,
    );
  }

  DecodeHint copyWith({
    bool? pureBarcode,
    bool? tryHarder,
    String? characterSet,
    bool? assumeGs1,
    bool? alsoInverted,
  }) {
    return DecodeHint(
      pureBarcode: pureBarcode ?? this.pureBarcode,
      tryHarder: tryHarder ?? this.tryHarder,
      characterSet: characterSet ?? this.characterSet,
      assumeGs1: assumeGs1 ?? this.assumeGs1,
      alsoInverted: alsoInverted ?? this.alsoInverted,
    );
  }
}
