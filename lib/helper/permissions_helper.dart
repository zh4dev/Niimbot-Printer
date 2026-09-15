import 'dart:io';

import 'package:flutter/services.dart';
import 'package:niimbot_print/constants/key_constant.dart';
import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/constants/plugin_constant.dart';
import 'package:niimbot_print/helper/log_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static const MethodChannel _channel =
      MethodChannel(PluginConstant.niimbotPrint);

  Future<bool> isBluetoothPermissionGranted({bool requiresScan = false}) async {
    bool isGranted;
    if (Platform.isAndroid) {
      final sdkInt =
          await _channel.invokeMethod<int>(PluginConstant.getAndroidSdkInt) ??
              31;
      final permissions = sdkInt >= 31
          ? <Permission>[
              Permission.bluetoothConnect,
              if (requiresScan) Permission.bluetoothScan,
            ]
          : <Permission>[
              if (requiresScan) Permission.locationWhenInUse,
            ];
      if (permissions.isEmpty) {
        return true;
      }
      final statuses = await permissions.request();
      isGranted = permissions.every(
        (permission) => statuses[permission]?.isGranted ?? false,
      );
    } else {
      isGranted = await Permission.bluetooth.request().isGranted;
    }
    if (!isGranted) {
      LogHelper.error(MessageConstant.bluetoothPermissionsNotGranted,
          event: KeyConstant.bluetoothPermissionStatus);
    }

    return isGranted;
  }
}
