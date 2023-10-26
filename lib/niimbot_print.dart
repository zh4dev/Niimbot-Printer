import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/constants/niimbot_model_constant.dart';
import 'package:niimbot_print/helper/bluetooth_helper.dart';
import 'package:niimbot_print/helper/permissions_helper.dart';
import 'package:niimbot_print/model/blue_device_info_model.dart';
import 'package:niimbot_print/model/print_label_model.dart';
import 'package:niimbot_print/niimbot_print_platform_interface.dart';
import 'package:collection/collection.dart';
export 'model/blue_device_info_model.dart';
export 'model/print_label_model.dart';
export 'constants/niimbot_model_constant.dart';

class NiimbotPrint {
  bool _isScanning = false;
  final BluetoothHelper bluetoothHelper = BluetoothHelper();
  final PermissionsHelper permissionsHelper = PermissionsHelper();

  Future<String?> _isAllPassed() async {
    var isBluetoothPermissionGranted =
        await permissionsHelper.isBluetoothPermissionGranted();
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

  /// Starts a scan for Nearest Hardware Bluetooth
  /// Timeout closes the stream after a specified [Duration]
  /// Add white list devices that you want to show using this Constant [NiimbotModelConstant]
  Future<List<BlueDeviceInfoModel>?> onStartScan(
      {Duration? scanDuration,
      List<String>? whiteListDevices,
      Function(String)? onError}) async {
    if (_isScanning) {
      onError?.call(MessageConstant.stillScanning);
      return [];
    }
    _isScanning = true;
    var errorMessage = await _isAllPassed();
    if (errorMessage != null) {
      onError?.call(errorMessage);
      return [];
    }
    var value = await NiimbotPrintPlatform.instance
        .onStartScan(scanDuration: scanDuration, onError: onError);
    _isScanning = false;
    if (whiteListDevices != null && value.isNotEmpty) {
      var filteredBluetoothList = <BlueDeviceInfoModel>[];
      for (var e1 in whiteListDevices) {
        var result = value.firstWhereOrNull((e2) {
          var deviceName = e2.deviceName?.toLowerCase() ?? '';
          return deviceName.startsWith(e1.toLowerCase());
        });
        if (result != null) {
          filteredBluetoothList.add(result);
        }
      }
      return filteredBluetoothList;
    }
    return value;
  }

  Future<void> onStartConnect(
      {required BlueDeviceInfoModel model,
      required Function(bool isSuccess, String message) onResult}) async {
    var errorMessage = await _isAllPassed();
    if (errorMessage != null) {
      onResult(false, errorMessage);
      return;
    }
    return NiimbotPrintPlatform.instance
        .onStartConnect(model: model, onResult: onResult);
  }

  Future<void> onStartPrintText(
      {required List<PrintLabelModel> printLabelModelList,
      required Function(bool isSuccess, String message) onResult}) async {
    var errorMessage = await _isAllPassed();
    if (errorMessage != null) {
      onResult(false, errorMessage);
      return;
    }
    return NiimbotPrintPlatform.instance.onStartPrintText(
        printLabelModelList: printLabelModelList, onResult: onResult);
  }

  Future<bool> onDisconnect() async {
    return NiimbotPrintPlatform.instance.onDisconnect();
  }
}
