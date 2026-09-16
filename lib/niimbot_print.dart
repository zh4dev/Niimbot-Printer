import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/enum/niimbot_model_enum.dart';
import 'package:niimbot_print/helper/bluetooth_helper.dart';
import 'package:niimbot_print/helper/permissions_helper.dart';
import 'package:niimbot_print/model/blue_device_info_model.dart';
import 'package:niimbot_print/model/print_label_model.dart';
import 'package:niimbot_print/model/print_qr_code_model.dart';
import 'package:niimbot_print/niimbot_print_platform_interface.dart';
export 'model/blue_device_info_model.dart';
export 'model/print_label_model.dart';
export 'model/print_qr_code_model.dart';
export 'enum/niimbot_model_enum.dart';

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

  /// Prints up to three non-empty text items on one label.
  ///
  /// Long values are wrapped at a word boundary into at most two lines. The
  /// native SDK then scales those lines to fit inside the field's text box.
  Future<void> onStartPrintText(
      {required List<PrintLabelModel> printLabelModelList,
      required NiimbotResultCallback onResult}) async {
    final errorMessage = await _isAllPassed();
    if (errorMessage != null) {
      onResult(false, errorMessage);
      return;
    }
    if (printLabelModelList.length > 3) {
      throw Exception(MessageConstant.maximumListIs3);
    }
    if (!printLabelModelList
        .any((element) => element.text?.trim().isNotEmpty ?? false)) {
      onResult(false, MessageConstant.emptyPrintData);
      return;
    }
    final formattedItems = printLabelModelList
        .map(
          (item) => item.copyWith(
            text: _wrapLabelText(item.text ?? ''),
          ),
        )
        .toList(growable: false);
    return NiimbotPrintPlatform.instance.onStartPrintText(
      printLabelModelList: formattedItems,
      onResult: onResult,
    );
  }

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

  /// Prints a QR code centered on a 50 x 30 mm label.
  Future<void> onStartPrintQrCode({
    required PrintQrCodeModel qrCode,
    required NiimbotResultCallback onResult,
  }) async {
    final data = qrCode.data.trim();
    if (data.isEmpty) {
      onResult(false, MessageConstant.emptyPrintData);
      return;
    }
    if (qrCode.size <= 0 || qrCode.size > 30) {
      onResult(false, MessageConstant.invalidQrSize);
      return;
    }
    final errorMessage = await _isAllPassed();
    if (errorMessage != null) {
      onResult(false, errorMessage);
      return;
    }
    return NiimbotPrintPlatform.instance.onStartPrintQrCode(
      qrCode: PrintQrCodeModel(data: data, size: qrCode.size),
      onResult: onResult,
    );
  }

  /// Disconnects the current printer.
  Future<bool> onDisconnect() => NiimbotPrintPlatform.instance.onDisconnect();

  /// Returns whether a printer is currently connected.
  Future<bool> isConnected() => NiimbotPrintPlatform.instance.isConnected();
}
