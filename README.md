## Features

Plugin for writing mindful minutes to Apple Health on iOS.

Features:
* Check for write permission
* Request write permission
* Write mindful minutes

This works on iOS 12 (other pub.dev health plugins require a higher iOS version, so I created my own).

## Getting started

* Add to pubspec.yaml
* Use plugin in your code (see examples of all methods below)
* Add permission for [NSHealthShareUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nshealthshareusagedescription) and [NSHealthUpdateUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nshealthupdateusagedescription) to `ios/Runner/info.plist`:

```
	<key>NSHealthShareUsageDescription</key>
	<string>This app would like to access mindful minutes.</string>
	<key>NSHealthUpdateUsageDescription</key>
	<string>This app would like to save mindful minutes.</string>
```

## Usage

```dart
final _plugin = MindfulMinutesPlugin();

final bool hasPermission = await _plugin.checkPermission();

final bool hasPermission = await _plugin.requestPermission();

await _plugin.writeMindfulMinutes(startTime, endTime);
```

## Important

iOS will ask the user only once per app for granting permissions. If the user disables it from iOS settings, it needs to be disabled from iOS settings.
