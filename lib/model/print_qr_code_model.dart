import 'package:niimbot_print/model/niimbot_print_element.dart';

enum NiimbotMatrixCodeType {
  qrCode(31),
  pdf417(32),
  dataMatrix(33),
  aztec(34);

  const NiimbotMatrixCodeType(this.nativeValue);
  final int nativeValue;
}

class PrintQrCodeModel extends NiimbotPrintElement {
  /// Creates a matrix code with optional dimensions in millimetres.
  ///
  /// When [frame] is omitted, the native renderer resolves its position using
  /// the alignments. Missing [width] or [height] is calculated automatically.
  const PrintQrCodeModel({
    required this.data,
    this.frame,
    this.width,
    this.height,
    this.horizontalAlignment = NiimbotElementAlignment.center,
    this.verticalAlignment = NiimbotElementAlignment.center,
    this.type = NiimbotMatrixCodeType.qrCode,
    this.rotation = NiimbotRotation.degree0,
  });

  /// Content encoded in the QR code.
  final String data;

  final NiimbotRect? frame;
  final double? width;
  final double? height;
  final NiimbotElementAlignment horizontalAlignment;
  final NiimbotElementAlignment verticalAlignment;
  final NiimbotMatrixCodeType type;
  final NiimbotRotation rotation;

  /// Converts this model to the map sent to the native SDK.
  @override
  Map<String, Object> toJson() => <String, Object>{
        'type': 'qrCode',
        'data': data,
        if (frame != null) 'frame': frame!.toJson(),
        if (width != null) 'width': width!,
        if (height != null) 'height': height!,
        'horizontalAlignment': horizontalAlignment.name,
        'verticalAlignment': verticalAlignment.name,
        'codeType': type.nativeValue,
        'rotation': rotation.degrees,
      };
}
