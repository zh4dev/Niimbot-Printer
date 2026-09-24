# Niimbot Print

A Flutter plugin for discovering, connecting to, and printing text labels or QR codes with
supported Niimbot Bluetooth printers on Android and iOS.

## Features

- Scan for nearby Niimbot printers.
- Filter scan results by supported printer model.
- Connect and disconnect over Bluetooth.
- Compose text, QR/matrix codes, barcodes, images, and lines in one request.
- Load images from bytes, files, URLs, or raw grayscale pixels.
- Generate native PNG previews before printing.
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
  niimbot_print: ^0.3.0
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

Enable the Bluetooth permission used by `permission_handler` in the host
application's `ios/Podfile`:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_BLUETOOTH=1',
      ]
    end
  end
end
```

After changing the Podfile, run `pod install` from the application's `ios`
directory. If Bluetooth permission was previously denied, enable it from iOS
Settings or reinstall the application so iOS can request it again.

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

One print request can combine text, QR codes, barcodes, images, and lines.

```dart
await niimbotPrint.onStartPrint(
  layout: const NiimbotLabelLayout(
    // Presets: mm50x30, mm50x80, and mm50x170.
    // Any positive dimensions can also be supplied with
    // NiimbotLabelSize.custom(width: 50, height: 120).
    size: NiimbotLabelSize.mm50x80,
    orientation: NiimbotLabelOrientation.landscape,
    horizontalAlignment: NiimbotLabelAlignment.center,
    verticalAlignment: NiimbotLabelAlignment.center,
    padding: 2,
  ),
  elements: [
    PrintLabelModel(
      text: 'Product name',
      font: NiimbotFontFamily.defaultFont,
      style: NiimbotFontStyle.bold,
      sizing: const NiimbotTextSizing.autoFit(
        minFontSize: 10,
        maxFontSize: 36,
        maxLines: 2,
        fontSizeOffset: 0,
      ),
    ),
    PrintLabelModel(
      text: 'SKU-0001',
      sizing: const NiimbotTextSizing.fixed(14),
    ),
  ],
  onResult: (isSuccess, message) {
    print(isSuccess ? 'Print succeeded: $message' : 'Print failed: $message');
  },
);
```

Label dimensions are expressed in millimetres. Landscape mode rotates the
logical canvas while preserving the physical media dimensions. A text item can
use either an exact font size with `NiimbotTextSizing.fixed` or select the
largest size within a range using `NiimbotTextSizing.autoFit`. Font families
are resolved by the native Niimbot SDK and must be present in the platform's
font resources; unsupported names fall back according to the SDK.

Each text item can independently use `NiimbotFontStyle.normal`, `bold`,
`italic`, `boldItalic`, `underline`, or `strikethrough`. Font style is optional
and defaults to `normal`, so existing print requests remain compatible.

Auto-fit items on the same label share one calculated base size. Set
`fontSizeOffset` to create a hierarchy such as `0`, `-2`, and `-4` while
keeping every text item within its configured bounds.

### Print a QR code

QR and matrix codes can use an explicit `frame`, or let the plugin calculate
their size and position. Both `width` and `height` are optional. When only one
is supplied, the other dimension uses the same value so the code stays square.
When both are omitted, the plugin chooses a square that fits the label.

```dart
await niimbotPrint.onStartPrint(
  elements: const [
    PrintQrCodeModel(
      data: 'https://example.com/products/SKU-0001',
      width: 22, // height is inferred as 22 mm
      horizontalAlignment: NiimbotElementAlignment.end,
      verticalAlignment: NiimbotElementAlignment.center,
      rotation: NiimbotRotation.degree90,
    ),
  ],
  onResult: (isSuccess, message) {
    print(isSuccess
        ? 'QR code printed: $message'
        : 'QR code print failed: $message');
  },
);
```

To position a code at exact coordinates instead, provide `frame`. An explicit
frame takes precedence over automatic dimensions and alignment.

### Print a barcode

Barcode dimensions, alignment, and rotation work the same way. If `width` is
omitted, it fills the available label width. If `height` is omitted, the plugin
chooses a readable height based on the label.

```dart
await niimbotPrint.onStartPrint(
  elements: const [
    NiimbotBarcodeElement(
      data: '123456789012',
      height: 12, // width is selected automatically
      type: NiimbotBarcodeType.code128,
      horizontalAlignment: NiimbotElementAlignment.center,
      verticalAlignment: NiimbotElementAlignment.end,
      rotation: NiimbotRotation.degree0,
    ),
  ],
  onResult: (success, message) {},
);
```

Available element alignments are `start`, `center`, and `end`, independently
for the horizontal and vertical axes. Rotation uses the safe
`NiimbotRotation.degree0`, `degree90`, `degree180`, or `degree270` enum and
defaults to `degree0`.

Automatic alignment positions an individual code; it is not a flow layout.
When two automatically positioned codes would overlap, validation fails before
calling the native SDK. Select different alignments or provide explicit frames
when composing multiple codes.

Text-only labels may omit frames and use automatic vertical flow. Once text is
mixed with a positioned code, image, or line, every text element must also have
an explicit frame so the canvas layout remains deterministic.

### Print images

Images require a frame and can come from a network URL, local file, or bytes:

```dart
final networkImage = await NiimbotImageElement.fromNetwork(
  uri: Uri.parse('https://example.com/logo.png'),
  frame: const NiimbotRect(x: 2, y: 2, width: 20, height: 20),
);

final fileImage = await NiimbotImageElement.fromFile(
  path: '/path/to/logo.png',
  frame: const NiimbotRect(x: 2, y: 2, width: 20, height: 20),
);

final bytesImage = NiimbotImageElement.bytes(
  bytes: imageBytes,
  frame: const NiimbotRect(x: 2, y: 2, width: 20, height: 20),
);

await niimbotPrint.onStartPrint(
  elements: [networkImage], // or fileImage / bytesImage
  onResult: (success, message) {},
);
```

### Print raw pixel data

Provide exactly `pixelWidth * pixelHeight` grayscale bytes. Values below 128
print black and values of 128 or more print white:

```dart
final pixels = Uint8List.fromList(List<int>.generate(
  96 * 48,
  (index) => ((index % 96) ~/ 8 + (index ~/ 96) ~/ 8).isEven ? 0 : 255,
));

final pixelImage = NiimbotImageElement.pixels(
  pixelWidth: 96,
  pixelHeight: 48,
  pixels: pixels,
  frame: const NiimbotRect(x: 5, y: 3, width: 40, height: 24),
);
```

### Print a line

```dart
const line = NiimbotLineElement(
  frame: NiimbotRect(x: 3, y: 14, width: 44, height: 0.8),
  style: NiimbotLineStyle.dashed,
  dashLength: 1,
  gapLength: 1,
  rotation: NiimbotRotation.degree0,
);
```

### Combine multiple elements

All element types can be sent in the same `onStartPrint` call. Frames and
dimensions are expressed in millimetres.

```dart
final logo = await NiimbotImageElement.fromNetwork(
  uri: Uri.parse('https://example.com/logo.png'),
  frame: const NiimbotRect(x: 2, y: 2, width: 12, height: 12),
);

await niimbotPrint.onStartPrint(
  layout: const NiimbotLabelLayout(size: NiimbotLabelSize.mm50x80),
  elements: [
    logo,
    const NiimbotBarcodeElement(
      data: '1234567890',
      width: 34,
      height: 10,
      horizontalAlignment: NiimbotElementAlignment.start,
      verticalAlignment: NiimbotElementAlignment.end,
      type: NiimbotBarcodeType.code128,
    ),
    const NiimbotLineElement(
      frame: NiimbotRect(x: 2, y: 36, width: 46, height: 0.5),
    ),
  ],
  onResult: (success, message) {},
);
```

### Generate a print preview

The returned PNG is generated by the native Niimbot rendering SDK and can be
displayed directly by Flutter:

```dart
final png = await niimbotPrint.generatePreview(
  layout: const NiimbotLabelLayout(size: NiimbotLabelSize.mm50x80),
  elements: const [
    PrintQrCodeModel(
      data: 'https://example.com',
      horizontalAlignment: NiimbotElementAlignment.center,
      verticalAlignment: NiimbotElementAlignment.center,
    ),
  ],
);

final preview = Image.memory(png);
```

### Handle validation errors

Printing validates the label, element bounds, QR dimensions, common barcode
formats, and automatic-code collisions before invoking Bluetooth or native
rendering. Use `onError` when the application needs a stable error code:

```dart
await niimbotPrint.onStartPrint(
  elements: elements,
  onError: (error) {
    print(error.code);         // NiimbotPrintErrorCode
    print(error.elementIndex); // null or the invalid element index
    print(error.message);
  },
  onResult: (success, message) {},
);
```

`generatePreview` throws `NiimbotPrintException` for validation and preview
failures, so it can be handled with a normal `try`/`catch` block.

### Disconnect

```dart
final disconnected = await niimbotPrint.onDisconnect();
```

## Complete example

See the [`example`](example/) directory for a complete Flutter application
that demonstrates scanning, connecting, configurable label sizes and
orientation, optional code dimensions, alignment, rotation, previewing, and
printing every supported element type.

## Author

- Created by [Gerzha Hayat Prakarsha](https://zh4dev.github.io/)
- [GitHub profile](https://github.com/zh4dev)
