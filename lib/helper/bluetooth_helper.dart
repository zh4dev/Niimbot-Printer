
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:niimbot_print/constants/key_constant.dart';
import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/helper/log_helper.dart';

class BluetoothHelper {

  Future<bool> isBluetoothEnabled() async {
    var isEnabled = (await BluetoothEnable.enableBluetooth) == true.toString();
    if (!isEnabled) {
      LogHelper.error(MessageConstant.bluetoothIsNotEnabled,
          event: KeyConstant.bluetoothStatus);
    }
    return isEnabled;
  }

}