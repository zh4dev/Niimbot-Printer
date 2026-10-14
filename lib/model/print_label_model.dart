import 'package:niimbot_print/enum/niimbot_font_family.dart';
import 'package:niimbot_print/enum/niimbot_font_style.dart';
import 'package:niimbot_print/enum/niimbot_text_alignment.dart';
import 'package:niimbot_print/model/niimbot_text_sizing.dart';
import 'package:niimbot_print/model/niimbot_print_element.dart';

class PrintLabelModel extends NiimbotPrintElement {
  PrintLabelModel({
    String? text,
    num? fontSize,
    NiimbotFontFamily? font,
    NiimbotFontStyle style = NiimbotFontStyle.normal,
    @Deprecated('Use font instead') String? fontFamily,
    NiimbotTextSizing? sizing,
    this.frame,
    this.rotation = NiimbotRotation.degree0,
    this.alignment,
  }) {
    _text = text;
    _fontSize = fontSize;
    _font = font;
    _style = style;
    _fontFamily = fontFamily;
    _sizing = sizing;
  }

  PrintLabelModel.fromJson(dynamic json) {
    _text = json['text'];
    _fontSize = json['fontSize'];
    _fontFamily = json['fontFamily'];
    frame = json['frame'] is Map
        ? NiimbotRect.fromJson(json['frame'] as Map<Object?, Object?>)
        : null;
    rotation = NiimbotRotation.fromDegrees(
      (json['rotation'] as num?)?.toInt() ?? 0,
    );
    final alignmentName = json['textAlignment'];
    if (alignmentName != null) {
      alignment = NiimbotTextAlignment.values.firstWhere(
        (value) => value.name == alignmentName,
        orElse: () => NiimbotTextAlignment.center,
      );
    }
    _style = NiimbotFontStyle.values.firstWhere(
      (value) => value.name == json['fontStyle'],
      orElse: () => NiimbotFontStyle.normal,
    );
    for (final value in NiimbotFontFamily.values) {
      if (value.nativeName == _fontFamily) {
        _font = value;
        break;
      }
    }
    if (json['sizing'] is Map<String, dynamic>) {
      _sizing = NiimbotTextSizing.fromJson(json['sizing']);
    }
  }

  String? _text;
  num? _fontSize;
  String? _fontFamily;
  NiimbotFontFamily? _font;
  NiimbotFontStyle _style = NiimbotFontStyle.normal;
  NiimbotTextSizing? _sizing;
  NiimbotRect? frame;
  NiimbotRotation rotation = NiimbotRotation.degree0;
  NiimbotTextAlignment? alignment;

  PrintLabelModel copyWith({
    String? text,
    num? fontSize,
    NiimbotFontFamily? font,
    NiimbotFontStyle? style,
    @Deprecated('Use font instead') String? fontFamily,
    NiimbotTextSizing? sizing,
    NiimbotRect? frame,
    NiimbotRotation? rotation,
    NiimbotTextAlignment? alignment,
  }) =>
      PrintLabelModel(
        text: text ?? _text,
        fontSize: fontSize ?? _fontSize,
        font: font ?? _font,
        style: style ?? _style,
        fontFamily: fontFamily ?? _fontFamily,
        sizing: sizing ?? _sizing,
        frame: frame ?? this.frame,
        rotation: rotation ?? this.rotation,
        alignment: alignment ?? this.alignment,
      );

  String? get text => _text;

  num? get fontSize => _fontSize;

  String? get fontFamily => _fontFamily;

  NiimbotFontFamily get font => _font ?? NiimbotFontFamily.defaultFont;

  NiimbotFontStyle get style => _style;

  NiimbotTextSizing get sizing =>
      _sizing ??
      (_fontSize != null
          ? NiimbotTextSizing.fixed(_fontSize!.toDouble())
          : const NiimbotTextSizing.autoFit());

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = 'text';
    map['text'] = _text;
    if (_fontSize != null) map['fontSize'] = _fontSize;
    map['fontFamily'] = _font?.nativeName ?? _fontFamily ?? font.nativeName;
    map['fontStyle'] = style.name;
    map['sizing'] = sizing.toJson();
    if (frame != null) map['frame'] = frame!.toJson();
    map['rotation'] = rotation.degrees;
    if (alignment != null) map['textAlignment'] = alignment!.name;
    return map;
  }
}
