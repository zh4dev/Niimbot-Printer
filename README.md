## Introduction
Niimbot-Printer is integrated with Niimbot Hardware that can printing the text by using this Plugin.

## Setup
1. Ios (Need to add permissions on Info.plist)
A. NSBluetoothAlwaysUsageDescription
B. NSBluetoothPeripheralUsageDescription

## Getting Started

1. First you need to Scan to find nearest niimbot printer
    `var value = await niimbotPrint.onStartScan(
    whiteListDevices: [NiimbotModelEnum.b1],
    onError: (errorMessage) {
      LogHelper.error(errorMessage, event: 'initializeData');
    });`
2. You have to connect one of those that we've scanned before
`   if (blueDeviceInfoModel.value.connectionState != null) {
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
   }`
3. Start printing
 `  await niimbotPrint.onStartPrintText(
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
   });`

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

Created By: Gerzha Hayat Prakarsha
Portfolio: https://zh4dev.github.io/
Github: https://github.com/zh4dev