# mindful_minutes

Write mindful minutes to Apple Health on iOS: check write permission, request authorization, and save a session. On other platforms, all methods return `false` without calling native code. On iOS devices where HealthKit is unavailable, they also return `false`.

Requires Flutter 3.10 or newer. The native plugin supports iOS 12 or newer; your Flutter version can require a higher deployment target (Flutter 3.47 requires iOS 15).

## Getting started

1. Add the dependency with `flutter pub add mindful_minutes`.
2. In Xcode, open your app's `ios/Runner.xcworkspace`, select the Runner target, and add the **HealthKit** capability under **Signing & Capabilities**. This adds the HealthKit entitlement. Choose signing that supports this capability for device builds.
3. Add a write-purpose description to `ios/Runner/Info.plist`:

```xml
<key>NSHealthUpdateUsageDescription</key>
<string>This app saves mindful sessions to Apple Health.</string>
```

The plugin requests write access only. If your app separately requests read access, also configure `NSHealthShareUsageDescription`. See Apple's [HealthKit setup](https://developer.apple.com/documentation/xcode/configuring-healthkit-access) and [write-purpose description](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSHealthUpdateUsageDescription).

## Usage

```dart
import 'package:mindful_minutes/mindful_minutes.dart';

Future<bool> saveOneMindfulMinute() async {
  const plugin = MindfulMinutesPlugin();
  var hasPermission = await plugin.checkPermission();
  if (!hasPermission) {
    final requestCompleted = await plugin.requestPermission();
    if (requestCompleted) hasPermission = await plugin.checkPermission();
  }
  if (!hasPermission) return false;

  final endTime = DateTime.now();
  return plugin.writeMindfulMinutes(
    endTime.subtract(const Duration(minutes: 1)),
    endTime,
  );
}
```

`requestPermission()` reports whether the authorization request completed, even when the user denied write access. Check `checkPermission()` afterward to determine whether saving is authorized. Previously denied access may need to be enabled in the app's Apple Health permissions.

On iOS, reversed intervals throw `ArgumentError`. Native failures propagate as `PlatformException`, including `PERMISSION_ERROR`, `SAVE_ERROR`, and `INVALID_ARGUMENTS`; handle these in your app. A missing plugin registration throws `MissingPluginException`.

## iOS: Swift Package Manager and CocoaPods

Both dependency managers are supported. This plugin's Swift Package Manager integration requires Flutter 3.41 or newer; use CocoaPods with older Flutter versions. Flutter enables Swift Package Manager by default from Flutter 3.44. The following global configuration flags remain available:

```sh
flutter config --enable-swift-package-manager
flutter config --no-enable-swift-package-manager
```

To choose CocoaPods for a particular app, add this to its `pubspec.yaml`:

```yaml
flutter:
  config:
    enable-swift-package-manager: false
```

Use `true` to opt in on Flutter 3.41–3.43. Follow Flutter's [migration guidance](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers) when switching an existing project.
