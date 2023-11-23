import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niimbot_print/constants/message_constant.dart';
import 'package:niimbot_print/helper/log_helper.dart';
import 'package:niimbot_print/niimbot_print.dart';
import 'package:niimbot_print_example/app/data/commons/constants/ui_constant.dart';
import 'package:niimbot_print_example/app/data/commons/helpers/base_controller_helper.dart';

class PrintController extends BaseControllerHelper {
  final niimbotPrint = NiimbotPrint();
  var deviceList = <BlueDeviceInfoModel>[].obs;
  var blueDeviceInfoModel = BlueDeviceInfoModel().obs;
  var isLoadingPrinting = false.obs;

  @override
  void onInit() {
    initializeData();
    super.onInit();
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
    if (value?.isNotEmpty ?? false) {
      deviceList.value = value!;
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

  Future<void> onStartPrint() async {
    isLoadingPrinting.value = true;
    await niimbotPrint.onStartPrintText(
        printLabelModelList: [
          PrintLabelModel(text: 'Gerzha Hayat Prakarsha', fontSize: 16),
          PrintLabelModel(
              text:
                  'https://www.linkedin.com/in/gerzha-hayat-prakarsha-09974899/',
              fontSize: 14),
        ],
        onResult: (isSuccess, message) async {
          await Future.delayed(const Duration(seconds: 2));
          isLoadingPrinting.value = false;
          if (isSuccess) {
            Get.snackbar(MessageConstant.printSucceed, message,
                snackPosition: SnackPosition.BOTTOM,
                colorText: Colors.white,
                borderRadius: BorderRadiusConstant.low,
                backgroundColor: Get.theme.primaryColor,
                margin: const EdgeInsets.only(
                    left: MarginSizeConstant.medium,
                    right: MarginSizeConstant.medium,
                    bottom: MarginSizeConstant.medium));
          } else {
            LogHelper.error(message, event: 'onStartPrint');
          }
        });
  }
}
