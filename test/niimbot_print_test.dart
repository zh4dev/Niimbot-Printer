import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  List<NiimbotPrintElement>? receivedElements;
  NiimbotLabelLayout? receivedLayout;

  @override
  Future<List<BlueDeviceInfoModel>> onStartScan({
    Duration? scanDuration,
    Function(String)? onError,
  }) async =>
      scanResults;

  @override
  Future<void> onStartPrint({
    required List<NiimbotPrintElement> elements,
    NiimbotLabelLayout layout = const NiimbotLabelLayout(),
    required Function(bool isSuccess, String message) onResult,
  }) async {
    receivedElements = elements;
    receivedLayout = layout;
    onResult(true, 'ok');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BluetoothHelper', () {
    test('waits for the adapter to become ready after an unknown state',
        () async {
      final states = Stream<BluetoothAdapterState>.fromIterable(
        const <BluetoothAdapterState>[
          BluetoothAdapterState.unknown,
          BluetoothAdapterState.on,
        ],
      );
      final helper = BluetoothHelper(
        adapterStateProvider: () => states,
        adapterReadyTimeout: const Duration(milliseconds: 100),
      );

      expect(await helper.isBluetoothEnabled(), isTrue);
    });

    test('returns false when the adapter does not become ready', () async {
      final helper = BluetoothHelper(
        adapterStateProvider: () =>
            Stream<BluetoothAdapterState>.value(BluetoothAdapterState.off),
        adapterReadyTimeout: const Duration(milliseconds: 10),
      );

      expect(await helper.isBluetoothEnabled(), isFalse);
    });
  });

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

    test('profiles can be replaced or disabled without changing print geometry',
        () async {
      const profile = NiimbotPrinterMediaProfile(
          printerName: 'MY-PRINTER',
          size: NiimbotLabelSize.mm50x80,
          horizontalCorrection: -1);
      const layout = NiimbotLabelLayout(
          size: NiimbotLabelSize.mm50x80,
          printerProfiles: [profile],
          usePrinterProfiles: false);
      await printer.onStartPrint(
          elements: [PrintLabelModel(text: 'Test')],
          layout: layout,
          onResult: (_, _) {});
      expect(platform.receivedLayout?.toJson()['usePrinterProfiles'], false);
      expect(platform.receivedLayout?.toJson()['printerProfiles'],
          [profile.toJson()]);
    });

    test('print and preview reject malformed profiles before native rendering',
        () async {
      const layout = NiimbotLabelLayout(printerProfiles: [
        NiimbotPrinterMediaProfile(
            printerName: '',
            size: NiimbotLabelSize.mm50x30,
            horizontalCorrection: -1),
      ]);
      bool? success;
      await printer.onStartPrint(
          elements: [PrintLabelModel(text: 'Test')],
          layout: layout,
          onResult: (value, _) => success = value);
      expect(success, false);
      expect(platform.receivedElements, isNull);
      expect(
          () => printer.generatePreview(
              elements: [PrintLabelModel(text: 'Test')], layout: layout),
          throwsA(isA<NiimbotPrintException>()));
    });

    test('small padding remains valid with default profiles', () async {
      await printer.onStartPrint(
          elements: [PrintLabelModel(text: 'Test')],
          layout: const NiimbotLabelLayout(padding: 0),
          onResult: (_, _) {});
      expect(platform.receivedElements, isNotNull);
    });

    test('QR code is forwarded through the unified print API', () async {
      bool? succeeded;
      await printer.onStartPrint(
        elements: const <NiimbotPrintElement>[
          PrintQrCodeModel(
            data: 'https://example.com',
            frame: NiimbotRect(x: 5, y: 5, width: 20, height: 20),
          ),
        ],
        onResult: (success, message) => succeeded = success,
      );

      expect(succeeded, isTrue);
      expect((platform.receivedElements?.single as PrintQrCodeModel).data,
          'https://example.com');
    });

    test('long label text wraps into two lines at a word boundary', () async {
      await printer.onStartPrint(
        elements: <PrintLabelModel>[
          PrintLabelModel(
            text: 'Flying Cape Technologies Pte Ltd',
            fontSize: 14,
          ),
        ],
        onResult: (success, message) {},
      );

      expect(
        (platform.receivedElements?.single as PrintLabelModel).text,
        'Flying Cape Technologies\nPte Ltd',
      );
    });

    test('explicit line breaks are limited to two lines', () async {
      await printer.onStartPrint(
        elements: <PrintLabelModel>[
          PrintLabelModel(text: 'First\nSecond\nThird', fontSize: 14),
        ],
        onResult: (success, message) {},
      );

      expect((platform.receivedElements?.single as PrintLabelModel).text,
          'First\nSecond Third');
    });

    test('custom label layout and auto-fit text are forwarded', () async {
      const layout = NiimbotLabelLayout(
        size: NiimbotLabelSize(width: 50, height: 170),
        orientation: NiimbotLabelOrientation.landscape,
      );
      await printer.onStartPrint(
        layout: layout,
        elements: <PrintLabelModel>[
          PrintLabelModel(
            text: 'A long attendee name that should be fitted automatically',
            font: NiimbotFontFamily.defaultFont,
            sizing: const NiimbotTextSizing.autoFit(
              minFontSize: 10,
              maxFontSize: 36,
              maxLines: 2,
            ),
          ),
        ],
        onResult: (success, message) {},
      );

      expect(platform.receivedLayout, same(layout));
      final text = platform.receivedElements?.single as PrintLabelModel;
      expect(text.text, contains('automatically'));
      expect(text.sizing.maxFontSize, 36);
    });

    test('rejects a non-square QR code before calling native code', () async {
      NiimbotPrintException? receivedError;
      bool? succeeded;

      await printer.onStartPrint(
        elements: const <NiimbotPrintElement>[
          PrintQrCodeModel(data: 'value', width: 20, height: 12),
        ],
        onError: (error) => receivedError = error,
        onResult: (success, message) => succeeded = success,
      );

      expect(succeeded, isFalse);
      expect(receivedError?.code, NiimbotPrintErrorCode.invalidDimensions);
      expect(receivedError?.elementIndex, 0);
      expect(platform.receivedElements, isNull);
    });

    test('rejects invalid barcode data before calling native code', () async {
      NiimbotPrintException? receivedError;

      await printer.onStartPrint(
        elements: const <NiimbotPrintElement>[
          NiimbotBarcodeElement(
            data: 'ABC',
            type: NiimbotBarcodeType.ean13,
          ),
        ],
        onError: (error) => receivedError = error,
        onResult: (success, message) {},
      );

      expect(receivedError?.code, NiimbotPrintErrorCode.invalidBarcodeData);
      expect(platform.receivedElements, isNull);
    });

    test('rejects overlapping automatically positioned codes', () async {
      NiimbotPrintException? receivedError;

      await printer.onStartPrint(
        elements: const <NiimbotPrintElement>[
          PrintQrCodeModel(data: 'first'),
          PrintQrCodeModel(data: 'second'),
        ],
        onError: (error) => receivedError = error,
        onResult: (success, message) {},
      );

      expect(
        receivedError?.code,
        NiimbotPrintErrorCode.overlappingAutoElements,
      );
      expect(receivedError?.elementIndex, 1);
      expect(platform.receivedElements, isNull);
    });

    test('rejects explicit frames outside the logical label bounds', () async {
      NiimbotPrintException? receivedError;

      await printer.onStartPrint(
        elements: const <NiimbotPrintElement>[
          NiimbotLineElement(
            frame: NiimbotRect(x: 45, y: 5, width: 10, height: 1),
          ),
        ],
        onError: (error) => receivedError = error,
        onResult: (success, message) {},
      );

      expect(receivedError?.code, NiimbotPrintErrorCode.elementOutOfBounds);
      expect(platform.receivedElements, isNull);
    });

    test('requires text frames when using mixed canvas elements', () async {
      NiimbotPrintException? receivedError;

      await printer.onStartPrint(
        elements: <NiimbotPrintElement>[
          PrintLabelModel(text: 'Unpositioned text'),
          const PrintQrCodeModel(
            data: 'positioned-code',
            width: 10,
            horizontalAlignment: NiimbotElementAlignment.end,
          ),
        ],
        onError: (error) => receivedError = error,
        onResult: (success, message) {},
      );

      expect(receivedError?.code, NiimbotPrintErrorCode.invalidDimensions);
      expect(receivedError?.elementIndex, 0);
      expect(platform.receivedElements, isNull);
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

      await MethodChannelNiimbotPrint().onStartPrint(
        elements: items,
        onResult: (success, message) {},
      );

      expect(items, hasLength(2));
      expect(sentArguments, isA<Map<Object?, Object?>>());
      final payload = sentArguments as Map<Object?, Object?>;
      expect(payload['items'], hasLength(2));
      expect(payload['layout'], <String, Object?>{
        'width': 50.0,
        'height': 30.0,
        'orientation': 'portrait',
        'horizontalAlignment': 'center',
        'verticalAlignment': 'center',
        'padding': 2.0,
        'textSpacing': 0.0,
        'horizontalCalibration': 0.0,
        'usePrinterProfiles': true,
        'printerProfiles': NiimbotPrinterMediaProfile.builtInProfiles
            .map((profile) => profile.toJson())
            .toList(),
      });
    });

    test('serializes size, orientation, font style, and auto-fit options',
        () async {
      Object? sentArguments;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        sentArguments = call.arguments;
        return true;
      });

      await MethodChannelNiimbotPrint().onStartPrint(
        layout: const NiimbotLabelLayout(
          size: NiimbotLabelSize(width: 50, height: 80),
          orientation: NiimbotLabelOrientation.landscape,
          textSpacing: 1,
          horizontalCalibration: -1.5,
        ),
        elements: <NiimbotPrintElement>[
          PrintLabelModel(
            text: 'VIP',
            font: NiimbotFontFamily.defaultFont,
            style: NiimbotFontStyle.boldItalic,
            alignment: NiimbotTextAlignment.right,
            sizing: const NiimbotTextSizing.autoFit(
              maxFontSize: 40,
              fontSizeOffset: -2,
            ),
          ),
        ],
        onResult: (success, message) {},
      );

      final payload = sentArguments as Map<Object?, Object?>;
      final item =
          jsonDecode((payload['items'] as List<Object?>).single as String)
              as Map<String, dynamic>;
      expect((payload['layout'] as Map<Object?, Object?>)['height'], 80.0);
      expect((payload['layout'] as Map<Object?, Object?>)['orientation'],
          'landscape');
      expect((payload['layout'] as Map<Object?, Object?>)['textSpacing'], 1.0);
      expect(
          (payload['layout'] as Map<Object?, Object?>)['horizontalCalibration'],
          -1.5);
      expect(item['fontFamily'], '宋体');
      expect(item['fontStyle'], 'boldItalic');
      expect(item['textAlignment'], 'right');
      expect(item['sizing']['mode'], 'autoFit');
      expect(item['sizing']['maxFontSize'], 40.0);
      expect(item['sizing']['fontSizeOffset'], -2.0);
    });

    test('mixed elements are serialized for the unified native channel',
        () async {
      MethodCall? receivedCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        receivedCall = call;
        return true;
      });

      await MethodChannelNiimbotPrint().onStartPrint(
        elements: const <NiimbotPrintElement>[
          PrintQrCodeModel(
            data: 'qr-value',
            frame: NiimbotRect(x: 2, y: 2, width: 18, height: 18),
          ),
          NiimbotBarcodeElement(
            data: '12345678',
            frame: NiimbotRect(x: 22, y: 2, width: 25, height: 10),
          ),
          NiimbotLineElement(
            frame: NiimbotRect(x: 2, y: 22, width: 45, height: 0.5),
          ),
        ],
        onResult: (success, message) {},
      );

      expect(receivedCall?.method, 'onStartPrint');
      final payload = receivedCall?.arguments as Map<Object?, Object?>;
      expect(payload['items'], hasLength(3));
      final qr = jsonDecode((payload['items'] as List).first as String);
      expect(qr['type'], 'qrCode');
    });

    test('codes serialize optional size, alignment, and rotation', () async {
      Object? sentArguments;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        sentArguments = call.arguments;
        return true;
      });

      await MethodChannelNiimbotPrint().onStartPrint(
        elements: const <NiimbotPrintElement>[
          PrintQrCodeModel(
            data: 'auto-sized-qr',
            width: 20,
            horizontalAlignment: NiimbotElementAlignment.end,
            verticalAlignment: NiimbotElementAlignment.start,
            rotation: NiimbotRotation.degree90,
          ),
          NiimbotBarcodeElement(
            data: '1234567890',
            height: 12,
            horizontalAlignment: NiimbotElementAlignment.center,
            verticalAlignment: NiimbotElementAlignment.end,
            rotation: NiimbotRotation.degree180,
          ),
        ],
        onResult: (success, message) {},
      );

      final payload = sentArguments as Map<Object?, Object?>;
      final items = (payload['items'] as List<Object?>)
          .cast<String>()
          .map((value) => jsonDecode(value) as Map<String, dynamic>)
          .toList();
      expect(items.first, isNot(contains('frame')));
      expect(items.first['width'], 20.0);
      expect(items.first, isNot(contains('height')));
      expect(items.first['horizontalAlignment'], 'end');
      expect(items.first['verticalAlignment'], 'start');
      expect(items.first['rotation'], 90);
      expect(items.last, isNot(contains('frame')));
      expect(items.last, isNot(contains('width')));
      expect(items.last['height'], 12.0);
      expect(items.last['horizontalAlignment'], 'center');
      expect(items.last['verticalAlignment'], 'end');
      expect(items.last['rotation'], 180);
    });

    test('preview returns native PNG bytes through the unified payload',
        () async {
      MethodCall? receivedCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        receivedCall = call;
        return Uint8List.fromList(<int>[137, 80, 78, 71]);
      });

      final preview = await MethodChannelNiimbotPrint().generatePreview(
        elements: <NiimbotPrintElement>[
          PrintLabelModel(text: 'Preview', fontSize: 14),
        ],
      );

      expect(receivedCall?.method, 'generatePreview');
      expect(preview, <int>[137, 80, 78, 71]);
    });

    test('raw pixels are encoded as a printable BMP image', () {
      final element = NiimbotImageElement.pixels(
        pixelWidth: 2,
        pixelHeight: 2,
        pixels: Uint8List.fromList(<int>[0, 255, 255, 0]),
        frame: const NiimbotRect(x: 0, y: 0, width: 10, height: 10),
      );
      final bytes = base64Decode(element.toJson()['imageData'] as String);

      expect(bytes.take(2), <int>[0x42, 0x4d]);
      expect(bytes.length, greaterThan(54));
    });
  });
}
