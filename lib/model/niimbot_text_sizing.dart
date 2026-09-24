enum NiimbotTextSizingMode { fixed, autoFit }

/// Selects either an exact font size or the largest size that fits its box.
class NiimbotTextSizing {
  const NiimbotTextSizing.fixed(double fontSize)
      : mode = NiimbotTextSizingMode.fixed,
        minFontSize = fontSize,
        maxFontSize = fontSize,
        maxLines = 1,
        fontSizeOffset = 0,
        assert(fontSize > 0);

  const NiimbotTextSizing.autoFit({
    this.minFontSize = 8,
    this.maxFontSize = 32,
    this.maxLines = 2,
    this.fontSizeOffset = 0,
  })  : mode = NiimbotTextSizingMode.autoFit,
        assert(minFontSize > 0),
        assert(maxFontSize >= minFontSize),
        assert(maxLines > 0);

  final NiimbotTextSizingMode mode;
  final double minFontSize;
  final double maxFontSize;
  final int maxLines;
  final double fontSizeOffset;

  factory NiimbotTextSizing.fromJson(Map<String, dynamic> json) {
    if (json['mode'] == NiimbotTextSizingMode.autoFit.name) {
      return NiimbotTextSizing.autoFit(
        minFontSize: (json['minFontSize'] as num?)?.toDouble() ?? 8,
        maxFontSize: (json['maxFontSize'] as num?)?.toDouble() ?? 32,
        maxLines: (json['maxLines'] as num?)?.toInt() ?? 2,
        fontSizeOffset: (json['fontSizeOffset'] as num?)?.toDouble() ?? 0,
      );
    }
    return NiimbotTextSizing.fixed(
      (json['maxFontSize'] as num?)?.toDouble() ?? 14,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mode': mode.name,
        'minFontSize': minFontSize,
        'maxFontSize': maxFontSize,
        'maxLines': maxLines,
        'fontSizeOffset': fontSizeOffset,
      };
}
