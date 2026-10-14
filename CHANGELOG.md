# Changelog

All notable changes to `niimbot_print` will be documented here.

## 0.3.2

- Move device/media policy into shared, configurable `NiimbotPrinterMediaProfile` data; add `usePrinterProfiles` to disable automatic correction.
- Route legacy Android text printing through the unified renderer.
- Cache up to 32 successful ink-bound measurements per session using hashed input keys and coordinates only; log render duration and cache hits.
- Prevent native preview from resetting the drawing board during an active print job.
- Share layout/profile preflight validation between printing and preview and reject non-finite dimensions.
- Add native Android and Foundation-only Objective-C tests for ink geometry, profile matching, calibration precedence, and cache behavior.

## 0.3.1

### Added

- Added configurable `textSpacing` between automatic-flow text elements.
- Added per-text `left`, `center`, and `right` alignment with layout fallback.
- Added horizontal text-flow calibration in millimetres, applied after centering and included in native previews.

### Fixed

- Wrap long text at word boundaries before rendering instead of shrinking it merely because it approaches a label edge.
- Reserve a small inner wrapping boundary so text moves to the next line before touching the label edge.
- Measure native preview ink bounds for horizontal and vertical text-flow centering instead of applying a guessed font-height correction.
- Calculate text-frame heights from the actual wrapped line count so the complete text block stays vertically centered.
- Apply the same text wrapping and centering behavior on Android and iOS.
- Apply an automatic -2 mm media-position correction for centered text flow on device B1-F729063519 with 50 x 30 mm portrait media. Other devices, media sizes, and alignments are unaffected; explicit calibration overrides the profile.
- Align the iOS podspec version with the Flutter package version.

## 0.3.0

### Added

- Added optional automatic width and height calculation for QR/matrix codes and barcodes.
- Added independent horizontal and vertical alignment for automatically positioned codes.
- Added optional code rotation while retaining explicit-frame positioning support.
- Expanded the example app and README with text, QR, barcode, network/file/byte images, lines, raw pixels, mixed-label printing, and native preview tutorials.
- Added `NiimbotRotation` so only native-supported rotations can be selected.
- Added structured `NiimbotPrintException` errors with stable error codes and invalid-element indexes.
- Added preflight validation for label bounds, QR proportions, common numeric barcode formats, code dimensions, and overlapping automatically positioned codes.
- Added an interactive example playground for label size, orientation, optional dimensions, alignment, rotation, preview, and printing.

## 0.2.1

### Fixed

- Corrected the native bold/italic flag order so `NiimbotFontStyle.bold` prints bold instead of italic on Android and iOS.

## 0.2.0

### Added

- Added the unified `onStartPrint` API for mixed text, QR/matrix code, barcode, image, line, and raw-pixel elements.
- Added images from bytes, local files, network URLs, and one-byte grayscale pixel buffers.
- Added native PNG print previews through `generatePreview`, using the same Niimbot renderer as physical printing.

### Removed

- Removed the separate `onStartPrintText` and `onStartPrintQrCode` APIs in favor of `onStartPrint`.

## 0.1.5

### Added

- Added per-text font styling through `NiimbotFontStyle`.
- Added native Android and iOS support for normal, bold, italic, bold italic, underline, and strikethrough text.

## 0.1.4

### Added

- Added `50 x 30`, `50 x 80`, and `50 x 170` mm label-size presets plus arbitrary custom dimensions.
- Added portrait and landscape canvas orientation with configurable padding and horizontal/vertical content alignment.
- Added per-text font-family selection through the discoverable `NiimbotFontFamily` enum.
- Added fixed and automatic font sizing with configurable minimum size, maximum size, and line limit.
- Added shared auto-fit sizing with per-text offsets for consistent typographic hierarchy.

### Fixed

- Fixed iOS label printing being aborted when `drawLableText` reports a false-negative result.
- Fixed connected printers being treated as disconnected on iOS by checking both the native connection state and active printer name.
- Fixed successful iOS connections unexpectedly returning users to an empty printer scan screen when printing.

### Changed

- Generate and validate label JSON before starting the physical print job, following the official Niimbot iOS SDK demo flow.
- Continue generating label JSON when an individual SDK draw call reports `NO`, and fail only when no valid label data is generated.
- Added native diagnostic logging for connection status and label drawing parameters.

## 0.1.3

### Fixed

- Fixed false “Enable Bluetooth” warnings on iOS after granting Bluetooth permission or enabling Bluetooth.
- Wait up to three seconds for CoreBluetooth to transition from `unknown` or `off` to `on`.
- Fixed iOS label text rendering failures that caused the “Unable to draw label content” error.
- Preserve label font sizes when long text wraps onto two lines.
- Added explicit errors for missing font resources, font initialization failures, and print timeouts.

### Changed

- Updated iOS font initialization to follow the official Niimbot SDK v4.1.1 implementation.
- Updated drawing-board initialization to use `ZT001.ttf` through `fontArray`.
- Added a 30-second native print timeout.

### Added

- Added official iOS font resources: `FONT.json`, `ZT001.ttf`, and `ZT002.otf`.
- Added tests for delayed Bluetooth initialization and disabled Bluetooth states.

## 0.1.2

- Isolate Android discovery results per scan so stale devices are never returned by a later scan.
- Add horizontal text safe margins so long label text auto-shrinks instead of being clipped.
- Wrap long text at word boundaries into at most two lines before printing.
- Keep the iOS podspec, example deployment target, and CocoaPods lockfile aligned with the package version.

## 0.1.1

- Correct the package homepage metadata.

## 0.1.0

- Include the required native iOS libraries in the published package.
- Refresh the installation, platform setup, and usage documentation.
- Add QR code printing on Android and iOS.
- Upgrade the bundled Android SDK to 4.1.1 and the iOS JCAPI SDK to 3.2.8.
- Include the Android LPAPI dependency required by supported third-party printer paths.
- Correct the Android QR code type and rotation argument order.
- Fix Android connection result fall-through and scan lifecycle handling.
- Fix the iOS scan timeout unit and guard native result callbacks.
- Correct Bluetooth permissions for Android 12 and earlier.
- Add Dart, native, and integration test coverage.
- Update the Android example to AGP 9.1, Gradle 9.3, Java 17, and SDK 37.

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
