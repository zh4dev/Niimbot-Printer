import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niimbot_print/helper/bluetooth_helper.dart';
import 'package:niimbot_print/helper/permissions_helper.dart';
import 'package:niimbot_print/niimbot_print.dart';
import 'package:niimbot_print/niimbot_print_method_channel.dart';
import 'package:niimbot_print/niimbot_print_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _AllowedPermissions extends PermissionsHelper {
  @override
  Future<bool> isBluetoothPermissionGranted(
          {bool requiresScan = false}) async =>
      true;
}

class _EnabledBluetooth extends BluetoothHelper {
  @override
  Future<bool> isBluetoothEnabled() async => true;
}

class _FakePlatform extends NiimbotPrintPlatform
    with MockPlatformInterfaceMixin {
  List<BlueDeviceInfoModel> scanResults = <BlueDeviceInfoModel>[];
  PrintQrCodeModel? receivedQrCode;

  @override
  Future<List<BlueDeviceInfoModel>> onStartScan({
    Duration? scanDuration,
    Function(String)? onError,
  }) async =>
      scanResults;

  @override
  Future<void> onStartPrintQrCode({
    required PrintQrCodeModel qrCode,
    required Function(bool isSuccess, String message) onResult,
  }) async {
    receivedQrCode = qrCode;
    onResult(true, 'ok');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NiimbotPrint', () {
    late NiimbotPrintPlatform originalPlatform;
    late _FakePlatform platform;
    late NiimbotPrint printer;

    setUp(() {
      originalPlatform = NiimbotPrintPlatform.instance;
      platform = _FakePlatform();
      NiimbotPrintPlatform.instance = platform;
      printer = NiimbotPrint(
        bluetoothHelper: _EnabledBluetooth(),
        permissionsHelper: _AllowedPermissions(),
      );
    });

    tearDown(() {
      NiimbotPrintPlatform.instance = originalPlatform;
    });

    test('scan filter returns every matching printer', () async {
      platform.scanResults = <BlueDeviceInfoModel>[
        BlueDeviceInfoModel(deviceName: 'B1-one'),
        BlueDeviceInfoModel(deviceName: 'B1-two'),
        BlueDeviceInfoModel(deviceName: 'B21-three'),
      ];

      final devices = await printer.onStartScan(
        whiteListDevices: const <NiimbotModelEnum>[NiimbotModelEnum.b1],
      );

      expect(devices.map((device) => device.deviceName),
          <String?>['B1-one', 'B1-two']);
    });

    test('QR code is trimmed and forwarded to the platform', () async {
      bool? succeeded;
      await printer.onStartPrintQrCode(
        qrCode: const PrintQrCodeModel(data: '  https://example.com  '),
        onResult: (success, message) => succeeded = success,
      );

      expect(succeeded, isTrue);
      expect(platform.receivedQrCode?.data, 'https://example.com');
      expect(platform.receivedQrCode?.size, 20);
    });

    test('invalid QR code size does not reach the platform', () async {
      String? errorMessage;
      await printer.onStartPrintQrCode(
        qrCode: const PrintQrCodeModel(data: 'value', size: 31),
        onResult: (success, message) => errorMessage = message,
      );

      expect(errorMessage, contains('30 mm'));
      expect(platform.receivedQrCode, isNull);
    });
  });

  group('MethodChannelNiimbotPrint', () {
    const channel = MethodChannel('niimbot_print');

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('printing text does not mutate the caller list', () async {
      Object? sentArguments;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        sentArguments = call.arguments;
        return true;
      });
      final items = <PrintLabelModel>[
        PrintLabelModel(text: 'Printable', fontSize: 14),
        PrintLabelModel(text: '', fontSize: 14),
      ];

      await MethodChannelNiimbotPrint().onStartPrintText(
        printLabelModelList: items,
        onResult: (success, message) {},
      );

      expect(items, hasLength(2));
      expect(sentArguments, isA<List<Object?>>());
      expect(sentArguments as List<Object?>, hasLength(1));
    });

    test('QR code is serialized for the native channel', () async {
      MethodCall? receivedCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        receivedCall = call;
        return true;
      });

      await MethodChannelNiimbotPrint().onStartPrintQrCode(
        qrCode: const PrintQrCodeModel(data: 'qr-value', size: 18),
        onResult: (success, message) {},
      );

      expect(receivedCall?.method, 'onStartPrintQrCode');
      expect(
        jsonDecode(receivedCall?.arguments as String),
        <String, Object>{'data': 'qr-value', 'size': 18.0},
      );
    });
  });
}
