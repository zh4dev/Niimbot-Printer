import 'dart:typed_data';

import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/enum/niimbot_model_enum.dart';
import 'package:niimbot_print/helper/bluetooth_helper.dart';
import 'package:niimbot_print/helper/permissions_helper.dart';
import 'package:niimbot_print/model/blue_device_info_model.dart';
import 'package:niimbot_print/model/print_label_model.dart';
import 'package:niimbot_print/model/niimbot_label_layout.dart';
import 'package:niimbot_print/model/niimbot_text_sizing.dart';
import 'package:niimbot_print/model/niimbot_print_element.dart';
import 'package:niimbot_print/model/niimbot_print_exception.dart';
import 'package:niimbot_print/model/print_qr_code_model.dart';
import 'package:niimbot_print/niimbot_print_platform_interface.dart';
export 'model/blue_device_info_model.dart';
export 'model/print_label_model.dart';
export 'model/niimbot_label_layout.dart';
export 'model/niimbot_text_sizing.dart';
export 'model/niimbot_print_element.dart';
export 'model/niimbot_print_exception.dart';
export 'model/print_qr_code_model.dart';
export 'enum/niimbot_model_enum.dart';
export 'enum/niimbot_font_family.dart';
export 'enum/niimbot_font_style.dart';
export 'enum/niimbot_text_alignment.dart';

/// Callback invoked when a connect or print operation finishes.
typedef NiimbotResultCallback = void Function(bool isSuccess, String message);

/// Callback invoked when a scan cannot be started or completed.
typedef NiimbotErrorCallback = void Function(String message);

/// High-level API for discovering and printing with Niimbot printers.
class NiimbotPrint {
  static const int _maxLabelLineCharacters = 24;

  bool _isScanning = false;
  NiimbotPrint({
    BluetoothHelper? bluetoothHelper,
    PermissionsHelper? permissionsHelper,
  })  : bluetoothHelper = bluetoothHelper ?? BluetoothHelper(),
        permissionsHelper = permissionsHelper ?? PermissionsHelper();

  final BluetoothHelper bluetoothHelper;
  final PermissionsHelper permissionsHelper;

  Future<String?> _isAllPassed({bool requiresScan = false}) async {
    final isBluetoothPermissionGranted =
        await permissionsHelper.isBluetoothPermissionGranted(
      requiresScan: requiresScan,
    );
    if (isBluetoothPermissionGranted == false) {
      return MessageConstant.bluetoothPermissionsNotGranted;
    }
    if (isBluetoothPermissionGranted) {
      var isBluetoothEnabled = await bluetoothHelper.isBluetoothEnabled();
      if (isBluetoothEnabled == false) {
        return MessageConstant.bluetoothIsNotEnabled;
      }
    }
    return null;
  }

  /// Scans for nearby Bluetooth printers.
  ///
  /// [scanDuration] defaults to six seconds. When [whiteListDevices] is set,
  /// only devices whose names start with one of those model names are returned.
  Future<List<BlueDeviceInfoModel>> onStartScan(
      {Duration? scanDuration,
      List<NiimbotModelEnum>? whiteListDevices,
      NiimbotErrorCallback? onError}) async {
    if (_isScanning) {
      onError?.call(MessageConstant.stillScanning);
      return [];
    }

    _isScanning = true;
    try {
      final errorMessage = await _isAllPassed(requiresScan: true);
      if (errorMessage != null) {
        onError?.call(errorMessage);
        return [];
      }
      final value = await NiimbotPrintPlatform.instance
          .onStartScan(scanDuration: scanDuration, onError: onError);
      if (whiteListDevices == null || whiteListDevices.isEmpty) {
        return value;
      }
      final prefixes =
          whiteListDevices.map((model) => model.name.toLowerCase()).toSet();
      return value.where((device) {
        final name = device.deviceName?.toLowerCase() ?? '';
        return prefixes.any(name.startsWith);
      }).toList(growable: false);
    } finally {
      _isScanning = false;
    }
  }

  Future<void> onStartConnect(
      {required BlueDeviceInfoModel model,
      required NiimbotResultCallback onResult}) async {
    final errorMessage = await _isAllPassed();
    if (errorMessage != null) {
      onResult(false, errorMessage);
      return;
    }
    return NiimbotPrintPlatform.instance
        .onStartConnect(model: model, onResult: onResult);
  }

  /// Prints text, matrix codes, barcodes, images, and lines on one label.
  ///
  /// Fixed-size values retain the legacy two-line wrapping behaviour. Auto-fit
  /// values select the largest configured font size that fits the label.
  Future<void> onStartPrint(
      {required List<NiimbotPrintElement> elements,
      NiimbotLabelLayout layout = const NiimbotLabelLayout(),
      NiimbotPrintErrorCallback? onError,
      required NiimbotResultCallback onResult}) async {
    final validationError =
        _validateLayout(layout) ?? _validateElements(elements, layout);
    if (validationError != null) {
      onError?.call(validationError);
      onResult(false, validationError.message);
      return;
    }
    final errorMessage = await _isAllPassed();
    if (errorMessage != null) {
      final error = NiimbotPrintException(
        code: errorMessage == MessageConstant.bluetoothIsNotEnabled
            ? NiimbotPrintErrorCode.bluetoothDisabled
            : NiimbotPrintErrorCode.bluetoothPermissionDenied,
        message: errorMessage,
      );
      onError?.call(error);
      onResult(false, error.message);
      return;
    }
    final formattedItems = _formatElements(elements);
    return NiimbotPrintPlatform.instance.onStartPrint(
      elements: formattedItems,
      layout: layout,
      onResult: (success, message) {
        if (!success) {
          onError?.call(NiimbotPrintException(
            code: NiimbotPrintErrorCode.nativeFailure,
            message: message,
          ));
        }
        onResult(success, message);
      },
    );
  }

  /// Generates a PNG preview using the same native renderer as printing.
  Future<Uint8List> generatePreview({
    required List<NiimbotPrintElement> elements,
    NiimbotLabelLayout layout = const NiimbotLabelLayout(),
  }) {
    final validationError =
        _validateLayout(layout) ?? _validateElements(elements, layout);
    if (validationError != null) throw validationError;
    return NiimbotPrintPlatform.instance.generatePreview(
      elements: _formatElements(elements),
      layout: layout,
    );
  }

  static NiimbotPrintException? _validateLayout(NiimbotLabelLayout layout) {
    final width = layout.orientation == NiimbotLabelOrientation.landscape
        ? layout.size.height
        : layout.size.width;
    final height = layout.orientation == NiimbotLabelOrientation.landscape
        ? layout.size.width
        : layout.size.height;
    if (layout.size.width <= 0 ||
        !layout.size.width.isFinite ||
        !layout.size.height.isFinite ||
        !layout.padding.isFinite ||
        !layout.textSpacing.isFinite ||
        layout.size.height <= 0 ||
        layout.padding < 0 ||
        layout.textSpacing < 0 ||
        !layout.horizontalCalibration.isFinite ||
        layout.horizontalCalibration.abs() > layout.padding ||
        layout.padding * 2 >= width ||
        layout.padding * 2 >= height) {
      return const NiimbotPrintException(
        code: NiimbotPrintErrorCode.invalidLabelSize,
        message: 'Invalid label dimensions, padding, or text spacing',
      );
    }
    for (final profile in layout.printerProfiles) {
      if (profile.printerName.trim().isEmpty ||
          !profile.size.width.isFinite ||
          !profile.size.height.isFinite ||
          profile.size.width <= 0 ||
          profile.size.height <= 0 ||
          !profile.horizontalCorrection.isFinite) {
        return const NiimbotPrintException(
            code: NiimbotPrintErrorCode.invalidLabelSize,
            message: 'Invalid printer media profile');
      }
    }
    return null;
  }

  static NiimbotPrintException? _validateElements(
    List<NiimbotPrintElement> elements,
    NiimbotLabelLayout layout,
  ) {
    if (elements.isEmpty) {
      return NiimbotPrintException(
        code: NiimbotPrintErrorCode.emptyElements,
        message: MessageConstant.emptyPrintData,
      );
    }
    final canvasWidth = layout.orientation == NiimbotLabelOrientation.landscape
        ? layout.size.height
        : layout.size.width;
    final canvasHeight = layout.orientation == NiimbotLabelOrientation.landscape
        ? layout.size.width
        : layout.size.height;
    final usesTextFlow = elements.every(
      (element) => element is PrintLabelModel && element.frame == null,
    );
    final automaticFrames = <_IndexedFrame>[];
    for (var index = 0; index < elements.length; index++) {
      final element = elements[index];
      final frame = _explicitFrame(element);
      if (frame != null) {
        if (frame.x < 0 ||
            frame.y < 0 ||
            frame.width <= 0 ||
            frame.height <= 0) {
          return NiimbotPrintException(
            code: NiimbotPrintErrorCode.invalidDimensions,
            message:
                'Element frame must use positive dimensions and coordinates',
            elementIndex: index,
          );
        }
        if (frame.x + frame.width > canvasWidth ||
            frame.y + frame.height > canvasHeight) {
          return NiimbotPrintException(
            code: NiimbotPrintErrorCode.elementOutOfBounds,
            message: 'Element frame exceeds the logical label bounds',
            elementIndex: index,
          );
        }
      }
      if (element is PrintLabelModel &&
          (element.text?.trim().isEmpty ?? true)) {
        return NiimbotPrintException(
          code: NiimbotPrintErrorCode.emptyData,
          message: 'Text cannot be empty',
          elementIndex: index,
        );
      }
      if (!usesTextFlow &&
          element is PrintLabelModel &&
          element.frame == null) {
        return NiimbotPrintException(
          code: NiimbotPrintErrorCode.invalidDimensions,
          message:
              'Text requires an explicit frame when mixed with positioned elements',
          elementIndex: index,
        );
      }
      if (element is PrintQrCodeModel) {
        if (element.data.trim().isEmpty) {
          return NiimbotPrintException(
            code: NiimbotPrintErrorCode.emptyData,
            message: 'Matrix code data cannot be empty',
            elementIndex: index,
          );
        }
        final error = _validateOptionalDimensions(
          element.width,
          element.height,
          canvasWidth - layout.padding * 2,
          canvasHeight - layout.padding * 2,
          index,
        );
        if (error != null) return error;
        final qrWidth = element.frame?.width ?? element.width;
        final qrHeight = element.frame?.height ?? element.height;
        if (element.type == NiimbotMatrixCodeType.qrCode &&
            qrWidth != null &&
            qrHeight != null &&
            (qrWidth - qrHeight).abs() > 0.001) {
          return NiimbotPrintException(
            code: NiimbotPrintErrorCode.invalidDimensions,
            message: 'QR code width and height must be equal',
            elementIndex: index,
          );
        }
        if (element.frame == null) {
          automaticFrames.add(_IndexedFrame(
            index,
            _resolveCodeFrame(element, layout, canvasWidth, canvasHeight),
          ));
        }
      } else if (element is NiimbotBarcodeElement) {
        final barcodeError = _validateBarcode(element, index);
        if (barcodeError != null) return barcodeError;
        final error = _validateOptionalDimensions(
          element.width,
          element.height,
          canvasWidth - layout.padding * 2,
          canvasHeight - layout.padding * 2,
          index,
        );
        if (error != null) return error;
        if (element.frame == null) {
          automaticFrames.add(_IndexedFrame(
            index,
            _resolveCodeFrame(element, layout, canvasWidth, canvasHeight),
          ));
        }
      }
    }
    for (var left = 0; left < automaticFrames.length; left++) {
      for (var right = left + 1; right < automaticFrames.length; right++) {
        if (_overlaps(
            automaticFrames[left].frame, automaticFrames[right].frame)) {
          return NiimbotPrintException(
            code: NiimbotPrintErrorCode.overlappingAutoElements,
            message:
                'Automatically positioned code elements overlap; use different alignments or explicit frames',
            elementIndex: automaticFrames[right].index,
          );
        }
      }
    }
    return null;
  }

  static NiimbotPrintException? _validateOptionalDimensions(
    double? width,
    double? height,
    double availableWidth,
    double availableHeight,
    int index,
  ) {
    if ((width != null && (width <= 0 || width > availableWidth)) ||
        (height != null && (height <= 0 || height > availableHeight))) {
      return NiimbotPrintException(
        code: NiimbotPrintErrorCode.invalidDimensions,
        message:
            'Code dimensions must be positive and fit inside the label padding',
        elementIndex: index,
      );
    }
    return null;
  }

  static NiimbotPrintException? _validateBarcode(
    NiimbotBarcodeElement barcode,
    int index,
  ) {
    final data = barcode.data.trim();
    if (data.isEmpty) {
      return NiimbotPrintException(
        code: NiimbotPrintErrorCode.emptyData,
        message: 'Barcode data cannot be empty',
        elementIndex: index,
      );
    }
    final numeric = RegExp(r'^\d+$').hasMatch(data);
    final valid = switch (barcode.type) {
      NiimbotBarcodeType.upcA =>
        numeric && data.length >= 11 && data.length <= 12,
      NiimbotBarcodeType.upcE =>
        numeric && data.length >= 6 && data.length <= 8,
      NiimbotBarcodeType.ean8 =>
        numeric && data.length >= 7 && data.length <= 8,
      NiimbotBarcodeType.ean13 =>
        numeric && data.length >= 12 && data.length <= 13,
      NiimbotBarcodeType.itf => numeric && data.length.isEven,
      _ => true,
    };
    if (!valid) {
      return NiimbotPrintException(
        code: NiimbotPrintErrorCode.invalidBarcodeData,
        message: 'Data is invalid for ${barcode.type.name}',
        elementIndex: index,
      );
    }
    return null;
  }

  static NiimbotRect? _explicitFrame(NiimbotPrintElement element) =>
      switch (element) {
        PrintLabelModel() => element.frame,
        PrintQrCodeModel() => element.frame,
        NiimbotBarcodeElement() => element.frame,
        NiimbotLineElement() => element.frame,
        NiimbotImageElement() => element.frame,
        _ => null,
      };

  static NiimbotRect _resolveCodeFrame(
    NiimbotPrintElement element,
    NiimbotLabelLayout layout,
    double canvasWidth,
    double canvasHeight,
  ) {
    final availableWidth = canvasWidth - layout.padding * 2;
    final availableHeight = canvasHeight - layout.padding * 2;
    final isMatrix = element is PrintQrCodeModel;
    final requestedWidth =
        isMatrix ? element.width : (element as NiimbotBarcodeElement).width;
    final requestedHeight =
        isMatrix ? element.height : (element as NiimbotBarcodeElement).height;
    final horizontal = isMatrix
        ? element.horizontalAlignment
        : (element as NiimbotBarcodeElement).horizontalAlignment;
    final vertical = isMatrix
        ? element.verticalAlignment
        : (element as NiimbotBarcodeElement).verticalAlignment;
    late final double width;
    late final double height;
    if (isMatrix) {
      final defaultSize = (availableWidth < availableHeight
              ? availableWidth
              : availableHeight) *
          0.7;
      width = requestedWidth ?? requestedHeight ?? defaultSize;
      height = requestedHeight ?? width;
    } else {
      width = requestedWidth ?? availableWidth;
      final defaultHeight = canvasHeight * 0.28;
      height = requestedHeight ??
          (defaultHeight < 10
              ? (10 < availableHeight ? 10 : availableHeight)
              : (defaultHeight < availableHeight
                  ? defaultHeight
                  : availableHeight));
    }
    final x = switch (horizontal) {
      NiimbotElementAlignment.start => layout.padding,
      NiimbotElementAlignment.center => (canvasWidth - width) / 2,
      NiimbotElementAlignment.end => canvasWidth - layout.padding - width,
    };
    final y = switch (vertical) {
      NiimbotElementAlignment.start => layout.padding,
      NiimbotElementAlignment.center => (canvasHeight - height) / 2,
      NiimbotElementAlignment.end => canvasHeight - layout.padding - height,
    };
    return NiimbotRect(x: x, y: y, width: width, height: height);
  }

  static bool _overlaps(NiimbotRect a, NiimbotRect b) =>
      a.x < b.x + b.width &&
      a.x + a.width > b.x &&
      a.y < b.y + b.height &&
      a.y + a.height > b.y;

  static List<NiimbotPrintElement> _formatElements(
    List<NiimbotPrintElement> elements,
  ) =>
      elements
          .map((item) => item is PrintLabelModel
              ? item.copyWith(
                  text: item.sizing.mode == NiimbotTextSizingMode.autoFit
                      ? _normalizeLabelText(item.text ?? '')
                      : _wrapLabelText(item.text ?? ''),
                )
              : item)
          .toList(growable: false);

  static String _normalizeLabelText(String value) =>
      value.trim().replaceAll(RegExp(r'[ \t]+'), ' ');

  static String _wrapLabelText(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'[ \t]+'), ' ');
    if (normalized.isEmpty) {
      return normalized;
    }

    final explicitLines = normalized
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (explicitLines.length > 1) {
      return <String>[
        explicitLines.first,
        explicitLines.skip(1).join(' '),
      ].join('\n');
    }

    final text = explicitLines.first;
    if (text.length <= _maxLabelLineCharacters) {
      return text;
    }

    final breakAt = text.lastIndexOf(' ', _maxLabelLineCharacters);
    if (breakAt <= 0) {
      return text;
    }
    return '${text.substring(0, breakAt)}\n${text.substring(breakAt + 1)}';
  }

  /// Disconnects the current printer.
  Future<bool> onDisconnect() => NiimbotPrintPlatform.instance.onDisconnect();

  /// Returns whether a printer is currently connected.
  Future<bool> isConnected() => NiimbotPrintPlatform.instance.isConnected();
}

class _IndexedFrame {
  const _IndexedFrame(this.index, this.frame);

  final int index;
  final NiimbotRect frame;
}
