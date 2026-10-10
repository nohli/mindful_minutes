import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The class for writing mindful minutes to Apple Health.
/// On unsupported platforms, all methods return false without calling native code.
class MindfulMinutesPlugin {
  /// Creates a new instance of [MindfulMinutesPlugin].
  const MindfulMinutesPlugin();

  static const MethodChannel _channel = MethodChannel('mindful_minutes');
  static bool get _isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Checks if the app has permission to write mindful minutes to Apple Health.
  /// Returns a bool with the writing permission status.
  /// Returns false when HealthKit is unavailable or permission is not granted.
  /// Native errors are reported as [PlatformException].
  Future<bool> checkPermission() async {
    if (!_isSupported) return false;
    return await _channel.invokeMethod<bool?>('checkPermission') ?? false;
  }

  /// Requests the permission for writing mindful minutes to Apple Health.
  /// Returns whether the authorization prompt completed successfully, even if
  /// the user denied permission. Call [checkPermission] to check the result.
  /// Native errors are reported as [PlatformException].
  Future<bool> requestPermission() async {
    if (!_isSupported) return false;
    return await _channel.invokeMethod<bool?>('requestPermission') ?? false;
  }

  /// Writes mindful minutes to Apple Health.
  /// Returns whether HealthKit saved the sample, or false when unavailable.
  /// Throws [ArgumentError] on iOS if [endTime] precedes [startTime].
  /// Native errors are reported as [PlatformException].
  Future<bool> writeMindfulMinutes(
    DateTime startTime,
    DateTime endTime,
  ) async {
    if (!_isSupported) return false;
    if (endTime.isBefore(startTime)) {
      throw ArgumentError.value(endTime, 'endTime', 'Must be at or after startTime');
    }
    Map<String, int> args = {
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
    };
    return await _channel.invokeMethod<bool?>('saveMindfulMinutes', args) ?? false;
  }
}
