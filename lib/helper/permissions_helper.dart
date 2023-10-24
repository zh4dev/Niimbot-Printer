import 'package:niimbot_print/constants/key_constant.dart';
import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/helper/log_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  Future<bool> isBluetoothPermissionGranted() async {
    var statuses = await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
    var isGranted = ((statuses[Permission.bluetooth]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothAdvertise]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothConnect]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothScan]?.isGranted ?? false));
    if (!isGranted) {
      LogHelper.error(MessageConstant.bluetoothPermissionsNotGranted,
          event: KeyConstant.bluetoothPermissionStatus);
    }
    return isGranted;
  }
}
