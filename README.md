# Niimbot Print

A Flutter plugin for discovering, connecting to, and printing text labels or QR codes with
supported Niimbot Bluetooth printers on Android and iOS.

## Features

- Scan for nearby Niimbot printers.
- Filter scan results by supported printer model.
- Connect and disconnect over Bluetooth.
- Print up to three text items in a single print request.
- Print QR codes with configurable dimensions.
- Check the current printer connection state.

## Supported platforms

- Android (minimum SDK 19)
- iOS 12.0 or later

The package requires Flutter 3.44 or later.

This release bundles Niimbot Android SDK 4.1.1, image SDK 1.9.5, and iOS
JCAPI SDK 3.2.8. Applications do not need to add these native SDK files
separately.

Bluetooth printing should be tested on a physical device. Bluetooth features
and the bundled native Niimbot SDK might not work in a simulator or emulator.

## Supported printer models

The currently available model filters are:

- B1
- B3S
- B21
- ZZ401

## Installation

Add `niimbot_print` to your `pubspec.yaml`:

```yaml
dependencies:
  niimbot_print: ^0.1.2
```

Then install the dependency:

```sh
flutter pub get
```

## Platform setup

### iOS

Add the Bluetooth usage descriptions to `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app requires Bluetooth access to connect to Niimbot printers.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app requires Bluetooth access to communicate with Niimbot printers.</string>
```

The plugin includes the required native iOS libraries. No additional SDK
installation is required.

### Android

The required Bluetooth permissions and native Android libraries are included
by the plugin and merged into the application automatically. On Android 11 and
earlier, the system can request location permission because classic Bluetooth
discovery requires it. Android 12 and later uses the Nearby devices permission.

## Usage

Import the package and create a `NiimbotPrint` instance:

```dart
import 'package:niimbot_print/niimbot_print.dart';

final niimbotPrint = NiimbotPrint();
```

### Scan for printers

Use `whiteListDevices` to return only specific supported models. Omit it to
return all discovered Bluetooth devices.

```dart
final devices = await niimbotPrint.onStartScan(
  scanDuration: const Duration(seconds: 6),
  whiteListDevices: const [
    NiimbotModelEnum.b1,
    NiimbotModelEnum.b21,
  ],
  onError: (message) {
    print('Scan failed: $message');
  },
);

if (devices.isEmpty) {
  print('No Niimbot printer found.');
}
```

The plugin requests the required Bluetooth runtime permissions when scanning,
connecting, or printing. If permission is denied or Bluetooth is disabled, the
error callback receives an explanatory message.

### Connect to a printer

Pass one of the devices returned by `onStartScan`:

```dart
if (devices.isNotEmpty) {
  await niimbotPrint.onStartConnect(
    model: devices.first,
    onResult: (isSuccess, message) {
      print(isSuccess ? 'Connected: $message' : 'Connection failed: $message');
    },
  );
}
```

You can check the connection at any time:

```dart
final connected = await niimbotPrint.isConnected();
```

### Print text labels

A print request accepts at most three `PrintLabelModel` items. Items with empty
text are ignored, and passing more than three items throws an exception.

```dart
await niimbotPrint.onStartPrintText(
  printLabelModelList: [
    PrintLabelModel(text: 'Product name', fontSize: 16),
    PrintLabelModel(text: 'SKU-0001', fontSize: 14),
  ],
  onResult: (isSuccess, message) {
    print(isSuccess ? 'Print succeeded: $message' : 'Print failed: $message');
  },
);
```

### Print a QR code

QR codes are printed in the center of the plugin's 50 x 30 mm label canvas.
The `size` value is expressed in millimeters and must not exceed 30.

```dart
await niimbotPrint.onStartPrintQrCode(
  qrCode: const PrintQrCodeModel(
    data: 'https://example.com/products/SKU-0001',
    size: 22,
  ),
  onResult: (isSuccess, message) {
    print(isSuccess
        ? 'QR code printed: $message'
        : 'QR code print failed: $message');
  },
);
```

### Disconnect

```dart
final disconnected = await niimbotPrint.onDisconnect();
```

## Complete example

See the [`example`](example/) directory for a complete Flutter application
that demonstrates scanning, connecting, and printing.

## Author

- Created by [Gerzha Hayat Prakarsha](https://zh4dev.github.io/)
- [GitHub profile](https://github.com/zh4dev)
