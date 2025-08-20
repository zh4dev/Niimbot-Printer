# Niimbot Printer Flutter Plugin

## 📖 Introduction
**Niimbot-Printer** is a Flutter plugin that integrates with **Niimbot Hardware Printers**, allowing you to print text labels directly from your Flutter application.

---

## ⚙️ Setup

### iOS Permissions  
Add the following permissions to your **Info.plist**:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app requires Bluetooth access to connect to Niimbot printers.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app requires Bluetooth access to communicate with Niimbot printers.</string>
```

---

## 🚀 Getting Started

### 1. Scan for nearby Niimbot printers
```dart
var value = await niimbotPrint.onStartScan(
  whiteListDevices: [NiimbotModelEnum.b1],
  onError: (errorMessage) {
    LogHelper.error(errorMessage, event: 'initializeData');
  },
);
```

### 2. Connect to a scanned device
```dart
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
    },
  );
}
```

### 3. Start printing
```dart
await niimbotPrint.onStartPrintText(
  printLabelModelList: [
    PrintLabelModel(text: 'Gerzha Hayat Prakarsha', fontSize: 16),
    PrintLabelModel(
      text: 'https://www.linkedin.com/in/gerzha-hayat-prakarsha-09974899/',
      fontSize: 14,
    ),
  ],
  onResult: (isSuccess, message) async {
    await Future.delayed(const Duration(seconds: 2));
    isLoadingPrinting.value = false;

    if (isSuccess) {
      Get.snackbar(
        MessageConstant.printSucceed,
        message,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        borderRadius: BorderRadiusConstant.low,
        backgroundColor: Get.theme.primaryColor,
        margin: const EdgeInsets.only(
          left: MarginSizeConstant.medium,
          right: MarginSizeConstant.medium,
          bottom: MarginSizeConstant.medium,
        ),
      );
    } else {
      LogHelper.error(message, event: 'onStartPrint');
    }
  },
);
```

---

## 📦 About this project
This project is a starting point for a Flutter  
[plugin package](https://flutter.dev/developing-packages/),  
a specialized package that includes platform-specific implementation code for Android and/or iOS.

---

## 👤 Author
- **Created By:** Gerzha Hayat Prakarsha  
- **Portfolio:** [https://zh4dev.dev/](https://zh4dev.dev/)  
- **GitHub:** [https://github.com/zh4dev](https://github.com/zh4dev)  
