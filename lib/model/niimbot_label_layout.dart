enum NiimbotLabelOrientation { portrait, landscape }

enum NiimbotLabelAlignment { start, center, end }

/// Physical label dimensions in millimetres.
class NiimbotLabelSize {
  const NiimbotLabelSize({required this.width, required this.height})
      : assert(width > 0),
        assert(height > 0);

  static const mm50x30 = NiimbotLabelSize(width: 50, height: 30);
  static const mm50x80 = NiimbotLabelSize(width: 50, height: 80);
  static const mm50x170 = NiimbotLabelSize(width: 50, height: 170);

  factory NiimbotLabelSize.custom({
    required double width,
    required double height,
  }) = NiimbotLabelSize;

  final double width;
  final double height;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'width': width,
        'height': height,
      };
}

/// Controls the physical canvas and placement of all text on a label.
class NiimbotLabelLayout {
  const NiimbotLabelLayout({
    this.size = NiimbotLabelSize.mm50x30,
    this.orientation = NiimbotLabelOrientation.portrait,
    this.horizontalAlignment = NiimbotLabelAlignment.center,
    this.verticalAlignment = NiimbotLabelAlignment.center,
    this.padding = 2,
  }) : assert(padding >= 0);

  final NiimbotLabelSize size;
  final NiimbotLabelOrientation orientation;
  final NiimbotLabelAlignment horizontalAlignment;
  final NiimbotLabelAlignment verticalAlignment;
  final double padding;

  Map<String, dynamic> toJson() => <String, dynamic>{
        ...size.toJson(),
        'orientation': orientation.name,
        'horizontalAlignment': horizontalAlignment.name,
        'verticalAlignment': verticalAlignment.name,
        'padding': padding,
      };
}
