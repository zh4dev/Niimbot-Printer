enum NiimbotPrintErrorCode {
  bluetoothPermissionDenied,
  bluetoothDisabled,
  invalidLabelSize,
  emptyElements,
  emptyData,
  invalidDimensions,
  elementOutOfBounds,
  overlappingAutoElements,
  invalidBarcodeData,
  nativeFailure,
  previewGenerationFailed,
}

/// A structured failure raised before or during label rendering.
class NiimbotPrintException implements Exception {
  const NiimbotPrintException({
    required this.code,
    required this.message,
    this.elementIndex,
  });

  final NiimbotPrintErrorCode code;
  final String message;
  final int? elementIndex;

  @override
  String toString() => elementIndex == null
      ? 'NiimbotPrintException(${code.name}): $message'
      : 'NiimbotPrintException(${code.name}, element $elementIndex): $message';
}

typedef NiimbotPrintErrorCallback = void Function(NiimbotPrintException error);
