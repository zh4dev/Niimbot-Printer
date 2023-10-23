import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/constants/niimbot_model_constant.dart';
import 'package:niimbot_print/model/blue_device_info_model.dart';
import 'package:niimbot_print/model/print_label_model.dart';
import 'package:niimbot_print/niimbot_print_platform_interface.dart';
import 'package:collection/collection.dart';

export 'model/blue_device_info_model.dart';
export 'model/print_label_model.dart';
export 'constants/niimbot_model_constant.dart';

class NiimbotPrint {
  bool _isScanning = false;

  /// Starts a scan for Bluetooth Low Energy devices
  /// Timeout closes the stream after a specified [Duration]
  /// Add white list devices that you want to show using this Constant [NiimbotModelConstant]
  Future<List<BlueDeviceInfoModel>?> onStartScan(
      {Duration? scanDuration, List<String>? whiteListDevices}) async {
    if (_isScanning) {
      throw Exception(MessageConstant.stillScanning);
    }
    _isScanning = true;
    var value = await NiimbotPrintPlatform.instance
        .onStartScan(scanDuration: scanDuration);
    _isScanning = false;
    if (whiteListDevices != null) {
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
    return NiimbotPrintPlatform.instance
        .onStartConnect(model: model, onResult: onResult);
  }

  Future<void> onStartPrintText(
      {required List<PrintLabelModel> printLabelModelList,
      required Function(bool isSuccess, String message) onResult}) async {
    return NiimbotPrintPlatform.instance.onStartPrintText(
        printLabelModelList: printLabelModelList, onResult: onResult);
  }

  Future<bool> onDisconnect() async {
    return NiimbotPrintPlatform.instance.onDisconnect();
  }
}
