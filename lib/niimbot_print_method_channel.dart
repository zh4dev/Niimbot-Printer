import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:niimbot_print/constants/key_constant.dart';
import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/constants/plugin_constant.dart';
import 'package:niimbot_print/helper/bluetooth_helper.dart';
import 'package:niimbot_print/helper/log_helper.dart';
import 'package:niimbot_print/helper/permissions_helper.dart';
import 'package:niimbot_print/model/blue_device_info_model.dart';
import 'package:niimbot_print/model/print_label_model.dart';

import 'niimbot_print_platform_interface.dart';

class MethodChannelNiimbotPrint extends NiimbotPrintPlatform {
  @visibleForTesting

  final methodChannel = const MethodChannel(PluginConstant.niimbotPrint);
  final PermissionsHelper permissionsHelper = PermissionsHelper();
  final BluetoothHelper bluetoothHelper = BluetoothHelper();

  @override
  Future<List<BlueDeviceInfoModel>> onStartScan(
      {Duration? scanDuration, Function(String)? onError}) async {
    try {
      List listString = await methodChannel.invokeMethod(
          PluginConstant.onStartScan,
          scanDuration?.inMilliseconds ??
              const Duration(seconds: 6).inMilliseconds);
      List<BlueDeviceInfoModel> listResult = [];
      await Future.forEach(
          listString,
              (element) => {
            listResult.add(BlueDeviceInfoModel.fromJson(
                jsonDecode(element.toString())))
          });
      return listResult;
    } on PlatformException catch (e) {
      onError?.call(e.message ?? MessageConstant.scanFailed);
      LogHelper.error(e, event: PluginConstant.onStartScan);
    }
    return [];
  }

  @override
  Future<void> onStartConnect(
      {required BlueDeviceInfoModel model,
      required Function(bool isSuccess, String message) onResult}) async {
    try {
      String result = await methodChannel.invokeMethod(
          PluginConstant.onStartConnect, jsonEncode(model.toJson()));
      if (result == KeyConstant.connectionSuccess) {
        onResult(true, MessageConstant.connectionSucceeded);
      } else if (result == KeyConstant.connectionFailed) {
        onResult(false, MessageConstant.connectionFailed);
      } else if (result == KeyConstant.failedPairing) {
        onResult(false, MessageConstant.failedPairing);
      } else {
        onResult(false, MessageConstant.unsupportedModels);
      }
    } on PlatformException catch (e) {
      LogHelper.error(e, event: PluginConstant.onStartConnect);
      onResult(false, e.message ?? MessageConstant.connectionFailed);
    }
  }

  @override
  Future<void> onStartPrintText(
      {required List<PrintLabelModel> printLabelModelList,
      required Function(bool isSuccess, String message) onResult}) async {
    try {
      printLabelModelList.removeWhere((element) => element.text?.isEmpty ?? true);
      var result = await methodChannel.invokeMethod(PluginConstant.onStartPrintText,
          printLabelModelList.map((e) => jsonEncode(e.toJson())).toList());
      if (result is bool) {
        if (result) {
          onResult(true, MessageConstant.printSucceed);
        } else {
          onResult(false, MessageConstant.printFailed);
        }
      } else {
        onResult(false, result);
      }
    } on PlatformException catch (e) {
      LogHelper.error(e, event: PluginConstant.onStartPrintText);
      onResult(false, e.message ?? MessageConstant.printFailed);
    }
  }

  @override
  Future<bool> onDisconnect() async {
    try {
      bool isSuccess =
      await methodChannel.invokeMethod(PluginConstant.onDisconnect);
      return isSuccess;
    } on PlatformException catch (e) {
      LogHelper.error(e, event: PluginConstant.onDisconnect);
      return false;
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      bool isSuccess =
      await methodChannel.invokeMethod(PluginConstant.isConnected);
      return isSuccess;
    } on PlatformException catch (e) {
      LogHelper.error(e, event: PluginConstant.isConnected);
      return false;
    }
  }
}
