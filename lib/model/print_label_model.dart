class PrintLabelModel {
  PrintLabelModel({
    String? text,
    num? fontSize,
  }) {
    _text = text;
    _fontSize = fontSize;
  }

  PrintLabelModel.fromJson(dynamic json) {
    _text = json['text'];
    _fontSize = json['fontSize'];
  }

  String? _text;
  num? _fontSize;

  PrintLabelModel copyWith({
    String? text,
    num? fontSize,
  }) =>
      PrintLabelModel(
        text: text ?? _text,
        fontSize: fontSize ?? _fontSize,
      );

  String? get text => _text;

  num? get fontSize => _fontSize;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['text'] = _text;
    map['fontSize'] = _fontSize;
    return map;
  }
}
