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

## Usage

```dart
final _plugin = MindfulMinutesPlugin();

final bool hasPermission = await _plugin.checkPermission();

final bool isPermissionGranted = await _plugin.requestPermission();

await _plugin.writeMindfulMinutes(startTime, endTime);
```
