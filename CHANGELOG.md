# Changelog

All notable changes to `niimbot_print` will be documented here.

## 0.0.6

- Fix the libs that are not found on android

## 0.0.5

- Update the Readme.md

## 0.0.4

- Improve Bluetooth scan and connect stability on Android and iOS.
- Internal cleanup of Gradle/iOS config and permission notes.
- Update the plugins and dependencies on Android.
- Remove Linux, Windows, and macOS from the supported platforms for better plugin compatibility.

## 0.0.3

- Add cross-platform declarations so the package is visible for Android, iOS, Windows, macOS, and Linux targets.¹
- Publish updated README with “Getting Started” steps and example code.
- Expose basic printing API:
    - `onStartScan(...)`
    - `onStartConnect(...)`
    - `onDisconnect()`
    - `onStartPrintText(...)`

## 0.0.2

- Integrate `flutter_blue_plus` for Bluetooth operations and `permission_handler` for runtime permissions.²
- Add simple example app demonstrating scan → connect → print text.
- Basic error handling and result callback plumbing.

## 0.0.1

- Initial publish scaffold for the Flutter plugin.
- Set up plugin structure and minimal platform code.
- Placeholder docs.

---

¹ Package page shows desktop platforms listed in metadata.  
² See dependencies listed on the package page.

