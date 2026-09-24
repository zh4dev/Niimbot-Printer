import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:niimbot_print/constants/key_constant.dart';
import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/constants/plugin_constant.dart';
import 'package:niimbot_print/helper/log_helper.dart';
import 'package:niimbot_print/model/blue_device_info_model.dart';
import 'package:niimbot_print/model/niimbot_label_layout.dart';
import 'package:niimbot_print/model/niimbot_print_element.dart';
import 'package:niimbot_print/model/niimbot_print_exception.dart';

import 'niimbot_print_platform_interface.dart';

class MethodChannelNiimbotPrint extends NiimbotPrintPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel(PluginConstant.niimbotPrint);
  @override
  Future<List<BlueDeviceInfoModel>> onStartScan(
      {Duration? scanDuration, Function(String)? onError}) async {
    try {
      final listString = await methodChannel.invokeListMethod<Object?>(
          PluginConstant.onStartScan,
          scanDuration?.inMilliseconds ??
              const Duration(seconds: 6).inMilliseconds);
      return (listString ?? const <Object?>[])
          .map((element) => BlueDeviceInfoModel.fromJson(
              jsonDecode(element.toString()) as Map<String, dynamic>))
          .toList(growable: false);
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
      final result = await methodChannel.invokeMethod<String>(
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
  Future<void> onStartPrint(
      {required List<NiimbotPrintElement> elements,
      NiimbotLabelLayout layout = const NiimbotLabelLayout(),
      required Function(bool isSuccess, String message) onResult}) async {
    try {
      final result = await methodChannel
          .invokeMethod<Object?>(PluginConstant.onStartPrint, <String, Object?>{
        'items':
            elements.map((e) => jsonEncode(e.toJson())).toList(growable: false),
        'layout': layout.toJson(),
      });
      if (result is bool) {
        if (result) {
          onResult(true, MessageConstant.printSucceed);
        } else {
          onResult(false, MessageConstant.printFailed);
        }
      } else {
        onResult(false, result?.toString() ?? MessageConstant.printFailed);
      }
    } on PlatformException catch (e) {
      LogHelper.error(e, event: PluginConstant.onStartPrint);
      onResult(false, e.message ?? MessageConstant.printFailed);
    }
  }

  @override
  Future<Uint8List> generatePreview({
    required List<NiimbotPrintElement> elements,
    NiimbotLabelLayout layout = const NiimbotLabelLayout(),
  }) async {
    try {
      final result = await methodChannel.invokeMethod<Uint8List>(
          PluginConstant.generatePreview, <String, Object?>{
        'items': elements
            .map((element) => jsonEncode(element.toJson()))
            .toList(growable: false),
        'layout': layout.toJson(),
      });
      if (result == null || result.isEmpty) {
        throw const NiimbotPrintException(
          code: NiimbotPrintErrorCode.previewGenerationFailed,
          message: 'Unable to generate print preview',
        );
      }
      return result;
    } on PlatformException catch (error) {
      LogHelper.error(error, event: PluginConstant.generatePreview);
      throw NiimbotPrintException(
        code: NiimbotPrintErrorCode.previewGenerationFailed,
        message: error.message ?? 'Unable to generate print preview',
      );
    }
  }

  @override
  Future<bool> onDisconnect() async {
    try {
      return await methodChannel
              .invokeMethod<bool>(PluginConstant.onDisconnect) ??
          false;
    } on PlatformException catch (e) {
      LogHelper.error(e, event: PluginConstant.onDisconnect);
      return false;
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      return await methodChannel
              .invokeMethod<bool>(PluginConstant.isConnected) ??
          false;
    } on PlatformException catch (e) {
      LogHelper.error(e, event: PluginConstant.isConnected);
      return false;
    }
  }
}
