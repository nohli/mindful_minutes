# mindful_minutes_example

Checks write permission, requests Apple Health authorization and saves a one-minute mindful session. Permission must be granted before saving. On non-iOS platforms, the plugin reports false.

The example and plugin require Flutter 3.47 or newer and Dart 3.13 or newer. The native plugin requires iOS 15+. Android and other unsupported platforms still return `false`.

For iOS device builds, enable HealthKit and configure signing as described in the [package setup](../README.md#getting-started). The example includes its HealthKit entitlement and purpose descriptions.

From this directory, select a compatible Flutter SDK with FVM, then run:

```sh
fvm flutter pub get
fvm flutter run -d <device-id>
```
