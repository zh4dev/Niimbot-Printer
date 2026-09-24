import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/model/blue_device_info_model.dart';
import 'package:niimbot_print/model/niimbot_label_layout.dart';
import 'package:niimbot_print/model/niimbot_print_element.dart';
import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'niimbot_print_method_channel.dart';

abstract class NiimbotPrintPlatform extends PlatformInterface {
  NiimbotPrintPlatform() : super(token: _token);

  static final Object _token = Object();

  static NiimbotPrintPlatform _instance = MethodChannelNiimbotPrint();

  static NiimbotPrintPlatform get instance => _instance;

  static set instance(NiimbotPrintPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<BlueDeviceInfoModel>> onStartScan(
      {Duration? scanDuration, Function(String)? onError}) async {
    throw UnimplementedError(MessageConstant.errorPlatformNotImplemented);
  }

  Future<void> onStartConnect(
      {required BlueDeviceInfoModel model,
      required Function(bool isSuccess, String message) onResult}) async {
    throw UnimplementedError(MessageConstant.errorPlatformNotImplemented);
  }

  Future<void> onStartPrint(
      {required List<NiimbotPrintElement> elements,
      NiimbotLabelLayout layout = const NiimbotLabelLayout(),
      required Function(bool isSuccess, String message) onResult}) async {
    throw UnimplementedError(MessageConstant.errorPlatformNotImplemented);
  }

  Future<Uint8List> generatePreview({
    required List<NiimbotPrintElement> elements,
    NiimbotLabelLayout layout = const NiimbotLabelLayout(),
  }) async {
    throw UnimplementedError(MessageConstant.errorPlatformNotImplemented);
  }

  Future<bool> onDisconnect() {
    throw UnimplementedError(MessageConstant.errorPlatformNotImplemented);
  }

  Future<bool> isConnected() {
    throw UnimplementedError(MessageConstant.errorPlatformNotImplemented);
  }
}
