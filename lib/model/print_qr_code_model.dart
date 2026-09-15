/// Configuration for a QR code printed on a 50 x 30 mm label.
class PrintQrCodeModel {
  /// Creates a QR code with [data] and an optional square [size] in millimeters.
  const PrintQrCodeModel({
    required this.data,
    this.size = 20,
  });

  /// Content encoded in the QR code.
  final String data;

  /// Width and height of the square QR code in millimeters.
  ///
  /// The supported range is greater than 0 and no larger than 30.
  final double size;

  /// Converts this model to the map sent to the native SDK.
  Map<String, Object> toJson() => <String, Object>{
        'data': data,
        'size': size,
      };
}
