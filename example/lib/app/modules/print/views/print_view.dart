import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:niimbot_print_example/app/data/commons/constants/string_constant.dart';
import 'package:niimbot_print_example/app/data/commons/constants/ui_constant.dart';
import 'package:niimbot_print_example/app/data/commons/widgets/loading_widget.dart';
import 'package:niimbot_print_example/app/data/commons/widgets/main_button_widget.dart';
import '../controllers/print_controller.dart';

class PrintView extends GetView<PrintController> {
  const PrintView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          bottomSheet: SizedBox(
            height: 45,
            child: MainButtonWidget(
              onPressed: controller.onStartPrint,
              text: TextConstant.startPrint,
              isLoading: controller.isLoadingPrinting.value,
              isDisable: (controller.blueDeviceInfoModel.value
                      .deviceHardwareAddress?.isEmpty ??
                  true) && controller.isLoadingPrinting.value,
            ),
          ).marginAll(MarginSizeConstant.medium),
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(MarginSizeConstant.medium),
              child: bluetoothListWidget()),
        ));
  }
}
