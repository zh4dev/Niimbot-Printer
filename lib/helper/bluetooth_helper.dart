
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:niimbot_print/constants/key_constant.dart';
import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/helper/log_helper.dart';

class BluetoothHelper {

  Future<bool> isBluetoothEnabled() async {
    var isEnabled = (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on);
    if (!isEnabled) {
      LogHelper.error(MessageConstant.bluetoothIsNotEnabled,
          event: KeyConstant.bluetoothStatus);
    }
    return isEnabled;
  }

}