import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:niimbot_print/constants/key_constant.dart';
import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/helper/log_helper.dart';

class BluetoothHelper {
  BluetoothHelper({
    Stream<BluetoothAdapterState> Function()? adapterStateProvider,
    this.adapterReadyTimeout = const Duration(seconds: 3),
  }) : _adapterStateProvider =
            adapterStateProvider ?? (() => FlutterBluePlus.adapterState);

  final Stream<BluetoothAdapterState> Function() _adapterStateProvider;
  final Duration adapterReadyTimeout;

  Future<bool> isBluetoothEnabled() async {
    var isEnabled = false;
    try {
      // On iOS, the first state after granting Bluetooth permission can be
      // `unknown` (or briefly `off`) while CoreBluetooth is initializing.
      // Wait for the ready state instead of treating that transient value as
      // a disabled adapter immediately.
      await _adapterStateProvider()
          .firstWhere((state) => state == BluetoothAdapterState.on)
          .timeout(adapterReadyTimeout);
      isEnabled = true;
    } on TimeoutException {
      isEnabled = false;
    } on StateError {
      // A finite/custom adapter stream can close without ever reporting `on`.
      isEnabled = false;
    }
    if (!isEnabled) {
      LogHelper.error(
        MessageConstant.bluetoothIsNotEnabled,
        event: KeyConstant.bluetoothStatus,
      );
    }
    return isEnabled;
  }
}
