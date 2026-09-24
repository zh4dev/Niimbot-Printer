import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/helper/log_helper.dart';
import 'package:niimbot_print/niimbot_print.dart';
import 'package:niimbot_print_example/app/data/commons/constants/ui_constant.dart';
import 'package:niimbot_print_example/app/data/commons/helpers/base_controller_helper.dart';

enum ExampleCodeKind { qrCode, barcode }

enum ExampleLabelPreset { mm50x30, mm50x80, mm50x170 }

class PrintController extends BaseControllerHelper {
  final niimbotPrint = NiimbotPrint();
  var deviceList = <BlueDeviceInfoModel>[].obs;
  var blueDeviceInfoModel = BlueDeviceInfoModel().obs;
  var isLoadingPrinting = false.obs;
  final codeDataController = TextEditingController(
    text: 'https://pub.dev/packages/niimbot_print',
  );
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final selectedCodeKind = ExampleCodeKind.qrCode.obs;
  final selectedHorizontalAlignment = NiimbotElementAlignment.center.obs;
  final selectedVerticalAlignment = NiimbotElementAlignment.center.obs;
  final selectedRotation = NiimbotRotation.degree0.obs;
  final selectedOrientation = NiimbotLabelOrientation.portrait.obs;
  final selectedLabelPreset = ExampleLabelPreset.mm50x30.obs;

  @override
  void onInit() {
    initializeData();
    super.onInit();
  }

  @override
  void onClose() {
    codeDataController.dispose();
    widthController.dispose();
    heightController.dispose();
    super.onClose();
  }

  NiimbotLabelLayout get playgroundLayout => NiimbotLabelLayout(
        size: switch (selectedLabelPreset.value) {
          ExampleLabelPreset.mm50x30 => NiimbotLabelSize.mm50x30,
          ExampleLabelPreset.mm50x80 => NiimbotLabelSize.mm50x80,
          ExampleLabelPreset.mm50x170 => NiimbotLabelSize.mm50x170,
        },
        orientation: selectedOrientation.value,
      );

  double? _optionalDimension(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : double.tryParse(value);
  }

  NiimbotPrintElement get configuredCodeElement {
    final width = _optionalDimension(widthController);
    final height = _optionalDimension(heightController);
    if (selectedCodeKind.value == ExampleCodeKind.qrCode) {
      return PrintQrCodeModel(
        data: codeDataController.text,
        width: width,
        height: height,
        horizontalAlignment: selectedHorizontalAlignment.value,
        verticalAlignment: selectedVerticalAlignment.value,
        rotation: selectedRotation.value,
      );
    }
    return NiimbotBarcodeElement(
      data: codeDataController.text,
      width: width,
      height: height,
      horizontalAlignment: selectedHorizontalAlignment.value,
      verticalAlignment: selectedVerticalAlignment.value,
      rotation: selectedRotation.value,
    );
  }

  void initializeData() async {
    setBusy();
    deviceList.clear();
    var value = await niimbotPrint.onStartScan(
        whiteListDevices: [NiimbotModelEnum.b1],
        onError: (errorMessage) {
          LogHelper.error(errorMessage, event: 'initializeData');
        });
    setIdle();
    if (value.isNotEmpty) {
      deviceList.value = value;
    }
  }

  void onSetDeviceLoading(
      {required BlueDeviceInfoModel device, required bool isLoading}) {
    device.isLoading = isLoading;
    deviceList.refresh();
  }

  void onConnectDevice(BlueDeviceInfoModel device) async {
    onSetDeviceLoading(device: device, isLoading: true);
    if (blueDeviceInfoModel.value.connectionState != null) {
      await niimbotPrint.onDisconnect();
      blueDeviceInfoModel.value = BlueDeviceInfoModel();
    } else {
      await niimbotPrint.onStartConnect(
          model: device,
          onResult: (isSuccess, message) {
            if (isSuccess) {
              blueDeviceInfoModel.value = device;
            } else {
              LogHelper.error(message, event: 'onConnectDevice');
              blueDeviceInfoModel.value = BlueDeviceInfoModel();
            }
          });
    }
    onSetDeviceLoading(device: device, isLoading: false);
  }

  Future<void> _print(
    List<NiimbotPrintElement> elements, {
    NiimbotLabelLayout layout = const NiimbotLabelLayout(),
  }) async {
    isLoadingPrinting.value = true;
    try {
      await niimbotPrint.onStartPrint(
        layout: layout,
        elements: elements,
        onError: (error) {
          LogHelper.error(error, event: error.code.name);
        },
        onResult: (isSuccess, message) {
          if (isSuccess) {
            Get.snackbar(MessageConstant.printSucceed, message,
                snackPosition: SnackPosition.BOTTOM,
                colorText: Colors.white,
                borderRadius: BorderRadiusConstant.low,
                backgroundColor: Get.theme.primaryColor,
                margin: const EdgeInsets.all(MarginSizeConstant.medium));
          } else {
            LogHelper.error(message, event: 'onStartPrint');
            Get.snackbar(
              'Unable to print',
              message,
              snackPosition: SnackPosition.BOTTOM,
              colorText: Colors.white,
              backgroundColor: Colors.red.shade700,
              margin: const EdgeInsets.all(MarginSizeConstant.medium),
            );
          }
        },
      );
    } finally {
      isLoadingPrinting.value = false;
    }
  }

  Future<void> onStartPrint() => _print([
        PrintLabelModel(
          text: 'Gerzha Hayat Prakarsha',
          style: NiimbotFontStyle.bold,
          sizing: const NiimbotTextSizing.autoFit(),
        ),
        PrintLabelModel(text: 'Niimbot Flutter Plugin', fontSize: 14),
      ]);

  Future<void> onPrintQrCode() async {
    await _print(
      const [
        PrintQrCodeModel(
          data: 'https://pub.dev/packages/niimbot_print',
          // No width/height: the plugin chooses a square size automatically.
          horizontalAlignment: NiimbotElementAlignment.center,
          verticalAlignment: NiimbotElementAlignment.center,
          rotation: NiimbotRotation.degree0,
        ),
      ],
    );
  }

  Future<void> onPrintBarcode() => _print(const [
        NiimbotBarcodeElement(
          data: '123456789012',
          height: 12,
          horizontalAlignment: NiimbotElementAlignment.center,
          verticalAlignment: NiimbotElementAlignment.center,
          rotation: NiimbotRotation.degree0,
        ),
      ]);

  Future<void> onPrintLine() => _print(const [
        NiimbotLineElement(
          frame: NiimbotRect(x: 3, y: 14, width: 44, height: 0.8),
          style: NiimbotLineStyle.dashed,
        ),
      ]);

  Future<void> onPrintNetworkImage() async {
    final image = await NiimbotImageElement.fromNetwork(
      uri: Uri.parse(
        'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/ui/layout/lakes.jpg',
      ),
      frame: const NiimbotRect(x: 10, y: 3, width: 30, height: 24),
    );
    await _print([image]);
  }

  /// Tutorial entry point for an image selected with any file picker.
  Future<void> onPrintFileImage(String path) async {
    final image = await NiimbotImageElement.fromFile(
      path: path,
      frame: const NiimbotRect(x: 10, y: 3, width: 30, height: 24),
    );
    await _print([image]);
  }

  /// Tutorial entry point for camera, screenshot, or generated image bytes.
  Future<void> onPrintImageBytes(Uint8List bytes) => _print([
        NiimbotImageElement.bytes(
          bytes: bytes,
          frame: const NiimbotRect(x: 10, y: 3, width: 30, height: 24),
        ),
      ]);

  Future<void> onPrintEmbeddedImageBytes() => onPrintImageBytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      );

  Future<void> onPrintPixels() {
    const width = 96;
    const height = 48;
    final pixels = Uint8List.fromList(List<int>.generate(
      width * height,
      (index) {
        final x = index % width;
        final y = index ~/ width;
        return (x ~/ 8 + y ~/ 8).isEven ? 0 : 255;
      },
    ));
    return _print([
      NiimbotImageElement.pixels(
        pixelWidth: width,
        pixelHeight: height,
        pixels: pixels,
        frame: const NiimbotRect(x: 5, y: 3, width: 40, height: 24),
      ),
    ]);
  }

  List<NiimbotPrintElement> _mixedElements() => [
        PrintLabelModel(
          text: 'NIIMBOT',
          frame: const NiimbotRect(x: 2, y: 2, width: 24, height: 7),
          style: NiimbotFontStyle.bold,
          sizing: const NiimbotTextSizing.autoFit(maxLines: 1),
        ),
        const PrintQrCodeModel(
          data: 'https://pub.dev/packages/niimbot_print',
          width: 16,
          horizontalAlignment: NiimbotElementAlignment.end,
          verticalAlignment: NiimbotElementAlignment.start,
        ),
        const NiimbotBarcodeElement(
          data: '1234567890',
          width: 34,
          height: 10,
          horizontalAlignment: NiimbotElementAlignment.start,
          verticalAlignment: NiimbotElementAlignment.end,
        ),
      ];

  Future<void> onPrintMixedLabel() => _print(_mixedElements());

  Future<void> onPrintConfiguredCode() => _print(
        [configuredCodeElement],
        layout: playgroundLayout,
      );

  Future<void> onShowConfiguredPreview() =>
      _showPreview([configuredCodeElement], layout: playgroundLayout);

  Future<void> onShowPreview() async {
    await _showPreview(_mixedElements());
  }

  Future<void> _showPreview(
    List<NiimbotPrintElement> elements, {
    NiimbotLabelLayout layout = const NiimbotLabelLayout(),
  }) async {
    try {
      final png = await niimbotPrint.generatePreview(
        layout: layout,
        elements: elements,
      );
      await Get.dialog<void>(
        AlertDialog(
          title: const Text('Native print preview'),
          content: Image.memory(png, fit: BoxFit.contain),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('Close')),
          ],
        ),
      );
    } on NiimbotPrintException catch (error) {
      Get.snackbar(
        error.code.name,
        error.message,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red.shade700,
        margin: const EdgeInsets.all(MarginSizeConstant.medium),
      );
    }
  }
}
