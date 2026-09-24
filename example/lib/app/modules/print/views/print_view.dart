import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niimbot_print/niimbot_print.dart';
import 'package:niimbot_print_example/app/data/commons/constants/string_constant.dart';
import 'package:niimbot_print_example/app/data/commons/constants/ui_constant.dart';
import 'package:niimbot_print_example/app/data/commons/widgets/loading_widget.dart';
import 'package:niimbot_print_example/app/data/commons/widgets/main_button_widget.dart';
import '../controllers/print_controller.dart';

class PrintView extends GetView<PrintController> {
  const PrintView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget dropdown<T>({
      required String label,
      required T value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T> onChanged,
    }) =>
        DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: items,
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        );

    String enumLabel(Enum value) => value.name
        .replaceAll('degree', '')
        .replaceAll('mm', '')
        .replaceAll('x', ' × ');

    Widget exampleButton({
      required String label,
      required VoidCallback onPressed,
      bool requiresPrinter = true,
    }) {
      final isDisconnected =
          controller.blueDeviceInfoModel.value.deviceHardwareAddress?.isEmpty ??
              true;
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: MainButtonWidget(
          onPressed: onPressed,
          text: label,
          isLoading: controller.isLoadingPrinting.value && requiresPrinter,
          isDisable: (requiresPrinter && isDisconnected) ||
              controller.isLoadingPrinting.value,
        ),
      );
    }

    Widget bluetoothListWidget() {
      if (controller.loadingStatus.value == true) {
        return LoadingWidget.listCardLoading();
      } else {
        if (controller.deviceList.isNotEmpty) {
          return Column(
            children: controller.deviceList
                .map((d) => Card(
                      elevation: 4,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BorderRadiusConstant.low)),
                      child: ListTile(
                        title: Text(
                          d.deviceName ?? '',
                          style: Get.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          d.deviceHardwareAddress ?? '',
                          style: Get.textTheme.bodyMedium,
                        ),
                        onTap: () => controller.onConnectDevice(d),
                        trailing: d.isLoading
                            ? LoadingWidget.customCircularProgressindicator(
                                size: 13)
                            : controller.blueDeviceInfoModel.value
                                        .deviceHardwareAddress ==
                                    d.deviceHardwareAddress
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : null,
                      ),
                    ))
                .toList(),
          );
        } else {
          return Text(
            TextConstant.emptyBluetoothDevice,
            style: Get.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ).marginOnly(top: MarginSizeConstant.medium);
        }
      }
    }

    return Obx(() => Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(55, kToolbarHeight),
            child: Material(
              child: AppBar(
                centerTitle: false,
                shadowColor: Colors.white70,
                title: Text(TextConstant.startPrint,
                    style: Get.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left),
                backgroundColor: Get.theme.primaryColor,
                actions: [
                  controller.loadingStatus.value == false
                      ? Center(
                          child: GestureDetector(
                            onTap: () => controller.initializeData(),
                            child: Text(
                              TextConstant.refresh,
                              style: Get.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ).marginOnly(right: MarginSizeConstant.medium),
                          ),
                        )
                      : LoadingWidget.customCircularProgressindicator(size: 13)
                          .marginOnly(
                              bottom: MarginSizeConstant.medium + 5,
                              top: MarginSizeConstant.medium + 5,
                              right: MarginSizeConstant.medium)
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(MarginSizeConstant.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                bluetoothListWidget(),
                const SizedBox(height: MarginSizeConstant.medium),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(MarginSizeConstant.medium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Code playground',
                          style: Get.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller.codeDataController,
                          decoration: const InputDecoration(
                            labelText: 'QR / barcode data',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = constraints.maxWidth >= 520
                                ? (constraints.maxWidth - 12) / 2
                                : constraints.maxWidth;
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: itemWidth,
                                  child: dropdown<ExampleCodeKind>(
                                    label: 'Code type',
                                    value: controller.selectedCodeKind.value,
                                    items: ExampleCodeKind.values
                                        .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(value ==
                                                      ExampleCodeKind.qrCode
                                                  ? 'QR code'
                                                  : 'Barcode (Code 128)'),
                                            ))
                                        .toList(),
                                    onChanged: (value) => controller
                                        .selectedCodeKind.value = value,
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: dropdown<ExampleLabelPreset>(
                                    label: 'Label size (mm)',
                                    value: controller.selectedLabelPreset.value,
                                    items: ExampleLabelPreset.values
                                        .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(enumLabel(value)),
                                            ))
                                        .toList(),
                                    onChanged: (value) => controller
                                        .selectedLabelPreset.value = value,
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: dropdown<NiimbotLabelOrientation>(
                                    label: 'Label orientation',
                                    value: controller.selectedOrientation.value,
                                    items: NiimbotLabelOrientation.values
                                        .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(value.name),
                                            ))
                                        .toList(),
                                    onChanged: (value) => controller
                                        .selectedOrientation.value = value,
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: dropdown<NiimbotRotation>(
                                    label: 'Rotation',
                                    value: controller.selectedRotation.value,
                                    items: NiimbotRotation.values
                                        .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(
                                                  '${value.degrees} degrees'),
                                            ))
                                        .toList(),
                                    onChanged: (value) => controller
                                        .selectedRotation.value = value,
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: dropdown<NiimbotElementAlignment>(
                                    label: 'Horizontal alignment',
                                    value: controller
                                        .selectedHorizontalAlignment.value,
                                    items: NiimbotElementAlignment.values
                                        .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(value.name),
                                            ))
                                        .toList(),
                                    onChanged: (value) => controller
                                        .selectedHorizontalAlignment
                                        .value = value,
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: dropdown<NiimbotElementAlignment>(
                                    label: 'Vertical alignment',
                                    value: controller
                                        .selectedVerticalAlignment.value,
                                    items: NiimbotElementAlignment.values
                                        .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(value.name),
                                            ))
                                        .toList(),
                                    onChanged: (value) => controller
                                        .selectedVerticalAlignment
                                        .value = value,
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: TextField(
                                    controller: controller.widthController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Width mm (empty = auto)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: TextField(
                                    controller: controller.heightController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Height mm (empty = auto)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        exampleButton(
                          label: 'Preview configured code',
                          onPressed: controller.onShowConfiguredPreview,
                          requiresPrinter: false,
                        ),
                        exampleButton(
                          label: 'Print configured code',
                          onPressed: controller.onPrintConfiguredCode,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: MarginSizeConstant.medium),
                Text(
                  'Other API examples',
                  style: Get.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                exampleButton(
                  label: 'Print text',
                  onPressed: controller.onStartPrint,
                ),
                exampleButton(
                  label: 'Print QR code (auto size)',
                  onPressed: controller.onPrintQrCode,
                ),
                exampleButton(
                  label: 'Print barcode (auto width)',
                  onPressed: controller.onPrintBarcode,
                ),
                exampleButton(
                  label: 'Print network image',
                  onPressed: controller.onPrintNetworkImage,
                ),
                exampleButton(
                  label: 'Print embedded image bytes',
                  onPressed: controller.onPrintEmbeddedImageBytes,
                ),
                exampleButton(
                  label: 'Print line',
                  onPressed: controller.onPrintLine,
                ),
                exampleButton(
                  label: 'Print raw pixels',
                  onPressed: controller.onPrintPixels,
                ),
                exampleButton(
                  label: 'Print mixed label',
                  onPressed: controller.onPrintMixedLabel,
                ),
                exampleButton(
                  label: 'Show native preview',
                  onPressed: controller.onShowPreview,
                  requiresPrinter: false,
                ),
                const SizedBox(height: MarginSizeConstant.medium),
              ],
            ),
          ),
        ));
  }
}
