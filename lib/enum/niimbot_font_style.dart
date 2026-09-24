/// Font styling supported by the native Niimbot drawing API.
enum NiimbotFontStyle {
  normal,
  bold,
  italic,
  boldItalic,
  underline,
  strikethrough;

  bool get isItalic => this == italic || this == boldItalic;

  bool get isBold => this == bold || this == boldItalic;

  bool get isUnderline => this == underline;

  bool get isStrikethrough => this == strikethrough;
}
