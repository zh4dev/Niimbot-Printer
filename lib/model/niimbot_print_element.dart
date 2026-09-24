import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// A rectangle expressed in millimetres on the logical label canvas.
class NiimbotRect {
  const NiimbotRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  factory NiimbotRect.fromJson(Map<Object?, Object?> json) => NiimbotRect(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
      );

  Map<String, Object> toJson() => <String, Object>{
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
}

/// Base type for every element accepted by the unified print API.
abstract class NiimbotPrintElement {
  const NiimbotPrintElement();

  Map<String, dynamic> toJson();
}

/// Alignment used when an element does not provide an explicit [NiimbotRect].
enum NiimbotElementAlignment { start, center, end }

/// Rotation values supported by the native Niimbot SDK.
enum NiimbotRotation {
  degree0(0),
  degree90(90),
  degree180(180),
  degree270(270);

  const NiimbotRotation(this.degrees);
  final int degrees;

  static NiimbotRotation fromDegrees(int degrees) => values.firstWhere(
        (value) => value.degrees == degrees,
        orElse: () => degree0,
      );
}

enum NiimbotBarcodeType {
  code128(20),
  upcA(21),
  upcE(22),
  ean8(23),
  ean13(24),
  code93(25),
  code39(26),
  codabar(27),
  itf(28);

  const NiimbotBarcodeType(this.nativeValue);
  final int nativeValue;
}

enum NiimbotBarcodeTextPosition {
  bottom(0),
  top(1),
  hidden(2);

  const NiimbotBarcodeTextPosition(this.nativeValue);
  final int nativeValue;
}

class NiimbotBarcodeElement extends NiimbotPrintElement {
  const NiimbotBarcodeElement({
    required this.data,
    this.frame,
    this.width,
    this.height,
    this.horizontalAlignment = NiimbotElementAlignment.center,
    this.verticalAlignment = NiimbotElementAlignment.center,
    this.type = NiimbotBarcodeType.code128,
    this.fontSize = 3,
    this.textHeight = 3,
    this.textPosition = NiimbotBarcodeTextPosition.bottom,
    this.rotation = NiimbotRotation.degree0,
  });

  final String data;
  final NiimbotRect? frame;
  final double? width;
  final double? height;
  final NiimbotElementAlignment horizontalAlignment;
  final NiimbotElementAlignment verticalAlignment;
  final NiimbotBarcodeType type;
  final double fontSize;
  final double textHeight;
  final NiimbotBarcodeTextPosition textPosition;
  final NiimbotRotation rotation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': 'barcode',
        'data': data,
        if (frame != null) 'frame': frame!.toJson(),
        if (width != null) 'width': width!,
        if (height != null) 'height': height!,
        'horizontalAlignment': horizontalAlignment.name,
        'verticalAlignment': verticalAlignment.name,
        'barcodeType': type.nativeValue,
        'fontSize': fontSize,
        'textHeight': textHeight,
        'textPosition': textPosition.nativeValue,
        'rotation': rotation.degrees,
      };
}

enum NiimbotLineStyle {
  solid(1),
  dashed(2);

  const NiimbotLineStyle(this.nativeValue);
  final int nativeValue;
}

class NiimbotLineElement extends NiimbotPrintElement {
  const NiimbotLineElement({
    required this.frame,
    this.style = NiimbotLineStyle.solid,
    this.dashLength = 1,
    this.gapLength = 1,
    this.rotation = NiimbotRotation.degree0,
  });

  final NiimbotRect frame;
  final NiimbotLineStyle style;
  final double dashLength;
  final double gapLength;
  final NiimbotRotation rotation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': 'line',
        'frame': frame.toJson(),
        'lineType': style.nativeValue,
        'dashWidth': <double>[dashLength, gapLength],
        'rotation': rotation.degrees,
      };
}

/// An image loaded from bytes, a local file, a URL, or raw grayscale pixels.
class NiimbotImageElement extends NiimbotPrintElement {
  NiimbotImageElement.bytes({
    required Uint8List bytes,
    required this.frame,
    this.rotation = NiimbotRotation.degree0,
    this.processingType = 1,
    this.threshold = 127,
  }) : _bytes = bytes;

  static Future<NiimbotImageElement> fromFile({
    required String path,
    required NiimbotRect frame,
    NiimbotRotation rotation = NiimbotRotation.degree0,
    int processingType = 1,
    double threshold = 127,
  }) async =>
      NiimbotImageElement.bytes(
        bytes: await File(path).readAsBytes(),
        frame: frame,
        rotation: rotation,
        processingType: processingType,
        threshold: threshold,
      );

  static Future<NiimbotImageElement> fromNetwork({
    required Uri uri,
    required NiimbotRect frame,
    Map<String, String> headers = const <String, String>{},
    NiimbotRotation rotation = NiimbotRotation.degree0,
    int processingType = 1,
    double threshold = 127,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      headers.forEach(request.headers.set);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Unable to load image: HTTP ${response.statusCode}',
          uri: uri,
        );
      }
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        builder.add(chunk);
      }
      return NiimbotImageElement.bytes(
        bytes: builder.takeBytes(),
        frame: frame,
        rotation: rotation,
        processingType: processingType,
        threshold: threshold,
      );
    } finally {
      client.close(force: true);
    }
  }

  /// Creates a printable BMP from one grayscale byte per pixel.
  /// Values below 128 are black; values of 128 or more are white.
  factory NiimbotImageElement.pixels({
    required int pixelWidth,
    required int pixelHeight,
    required Uint8List pixels,
    required NiimbotRect frame,
    NiimbotRotation rotation = NiimbotRotation.degree0,
  }) {
    if (pixelWidth <= 0 ||
        pixelHeight <= 0 ||
        pixels.length != pixelWidth * pixelHeight) {
      throw ArgumentError('Pixel dimensions do not match the pixel data');
    }
    return NiimbotImageElement.bytes(
      bytes: _encodeMonochromeBmp(pixelWidth, pixelHeight, pixels),
      frame: frame,
      rotation: rotation,
    );
  }

  final Uint8List _bytes;
  final NiimbotRect frame;
  final NiimbotRotation rotation;
  final int processingType;
  final double threshold;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': 'image',
        'frame': frame.toJson(),
        'imageData': base64Encode(_bytes),
        'rotation': rotation.degrees,
        'processingType': processingType,
        'threshold': threshold,
      };

  static Uint8List _encodeMonochromeBmp(
    int width,
    int height,
    Uint8List pixels,
  ) {
    final rowSize = ((width * 3 + 3) ~/ 4) * 4;
    final pixelDataSize = rowSize * height;
    final output = Uint8List(54 + pixelDataSize);
    final data = ByteData.sublistView(output);
    output[0] = 0x42;
    output[1] = 0x4d;
    data.setUint32(2, output.length, Endian.little);
    data.setUint32(10, 54, Endian.little);
    data.setUint32(14, 40, Endian.little);
    data.setInt32(18, width, Endian.little);
    data.setInt32(22, height, Endian.little);
    data.setUint16(26, 1, Endian.little);
    data.setUint16(28, 24, Endian.little);
    data.setUint32(34, pixelDataSize, Endian.little);
    for (var y = 0; y < height; y++) {
      final sourceY = height - 1 - y;
      final rowOffset = 54 + y * rowSize;
      for (var x = 0; x < width; x++) {
        final value = pixels[sourceY * width + x] < 128 ? 0 : 255;
        final offset = rowOffset + x * 3;
        output[offset] = value;
        output[offset + 1] = value;
        output[offset + 2] = value;
      }
    }
    return output;
  }
}
