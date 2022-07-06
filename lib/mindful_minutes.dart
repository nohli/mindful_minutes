library mindful_minutes;

import 'package:flutter/services.dart';

/// The class for writing mindful minutes to Apple Health.
class MindfulMinutesPlugin {
  static const MethodChannel _channel = MethodChannel('mindful_minutes');

  /// Checks if the app has writing permissions for mindful minutes.
  /// Returns false if the call was not successful.
  Future<bool> checkPermission() async {
    return await _channel.invokeMethod<bool?>('checkPermission') ?? false;
  }

  /// Checks if the app has writing permissions for mindful minutes.
  /// Returns false if the call was not successful.
  Future<bool> requestPermission() async {
    return await _channel.invokeMethod<bool?>('requestPermission') ?? false;
  }

  /// Writes mindful minutes to Apple Health.
  /// Returns false if the call was not successful.
  Future<bool> writeMindfulMinutes(
    DateTime startTime,
    DateTime endTime,
  ) async {
    Map<String, int> args = {
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch
    };
    return await _channel.invokeMethod<bool?>('saveMindfulMinutes', args) ??
        false;
  }
}
