import 'dart:io';

import 'package:niimbot_print/constants/key_constant.dart';
import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/helper/log_helper.dart';
// import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  Future<bool> isBluetoothPermissionGranted() async {
    return true;
    // bool isGranted = false;
    // if (Platform.isAndroid) {
    //   var statuses = await [
    //     Permission.bluetooth,
    //     Permission.bluetoothConnect,
    //     Permission.bluetoothScan,
    //   ].request();
    //   isGranted = ((statuses[Permission.bluetooth]?.isGranted ?? false) &&
    //       (statuses[Permission.bluetoothConnect]?.isGranted ?? false) &&
    //       (statuses[Permission.bluetoothScan]?.isGranted ?? false));
    // } else {
    //   var statuses = await [
    //     Permission.bluetooth,
    //   ].request();
    //   isGranted = (statuses[Permission.bluetooth]?.isGranted ?? false);
    // }
    // if (!isGranted) {
    //   LogHelper.error(MessageConstant.bluetoothPermissionsNotGranted,
    //       event: KeyConstant.bluetoothPermissionStatus);
    // }
    //
    // return isGranted;
  }
}
