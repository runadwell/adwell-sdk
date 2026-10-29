# adwell_sdk

Adwell for Flutter. It links Apple Ads installs to subscription revenue, so
Adwell can manage your keywords by what they earn. This is a thin bridge over
the native [AdwellSDK](https://github.com/runadwell/adwell-ios); all logic
lives there.

## Use

```dart
import 'package:adwell_sdk/adwell_sdk.dart';

await Adwell.configure(apiKey: 'pk_live_...');

// RevenueCat (purchases_flutter): on every launch, after Purchases.configure.
final id = await Adwell.installId;
if (id != null) await Purchases.setAttributes({'adwell_install_id': id});
```

Use a `pk_test_` key with `environment: AdwellEnvironment.staging`.
`logLevel: AdwellLogLevel.debug` prints what the SDK does in release builds too.

Nothing throws or blocks the UI. On web and desktop `configure` does nothing
and `installId` is null.

## Setup errors

In debug builds a wrong key, a key for the wrong environment, or a key for
another app is printed to the console as `[Adwell] Error: …`, and nothing is
sent. A working setup prints `[Adwell] Connected` once.

## Platforms

- **iOS 14+.** Builds with Swift Package Manager (depends on `adwell-ios` at
  the same version) or CocoaPods (uses a copy of it in `ios/vendor`).
- **Android.** Keeps an install id so billing attributes work the same way;
  sends nothing yet, because Apple Ads attribution is iOS only.

## Privacy

No IDFA, no tracking prompt, no personal data. AdwellSDK ships a privacy
manifest; see its README for what it sends.

## Release

Swift and Flutter versions move together (ADR 0002 D11):

1. Tag `adwell-ios` (e.g. `0.1.0`) and push the tag.
2. `tool/sync_ios.sh ../adwell-ios 0.1.0` refreshes `ios/vendor/AdwellSDK`.
3. Set the same version in `pubspec.yaml`, `ios/adwell_sdk.podspec`,
   `ios/adwell_sdk/Package.swift`, `android/build.gradle.kts` and
   `CHANGELOG.md`; `flutter test` checks they agree.
4. `flutter pub publish`.
