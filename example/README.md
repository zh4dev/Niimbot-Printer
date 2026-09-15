# Niimbot Print example

This application demonstrates how to:

- scan for nearby supported Niimbot printers;
- connect and disconnect over Bluetooth;
- print a text label; and
- print a QR code.

Run the example on a physical Android or iOS device:

```sh
flutter pub get
flutter run
```

Bluetooth printing is not expected to work in a simulator or emulator because
the bundled Niimbot SDK contains device-only native binaries.
