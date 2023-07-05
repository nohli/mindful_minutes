library mindful_minutes;

import 'package:flutter/services.dart';

/// The class for writing mindful minutes to Apple Health.
class MindfulMinutesPlugin {
  /// Creates a new instance of [MindfulMinutesPlugin].
  const MindfulMinutesPlugin();

  static const MethodChannel _channel = MethodChannel('mindful_minutes');

  /// Checks if the app has permission to write mindful minutes to Apple Health.
  /// Returns a bool with the writing permission status.
  /// Returns false if the call was not successful.
  Future<bool> checkPermission() async {
    return await _channel.invokeMethod<bool?>('checkPermission') ?? false;
  }

  /// Requests the permission for writing mindful minutes to Apple Health.
  /// Returns a bool whether the request was successful.
  Future<bool> requestPermission() async {
    return await _channel.invokeMethod<bool?>('requestPermission') ?? false;
  }

  /// Writes mindful minutes to Apple Health.
  /// Returns false if the call was not successful.
  Future<bool> writeMindfulMinutes(
    DateTime startTime,
    DateTime endTime,
  ) async {
    assert(!endTime.isBefore(startTime), 'startTime must be before endTime');
    Map<String, int> args = {
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
    };
    final isSuccess = await _channel.invokeMethod<bool?>('saveMindfulMinutes', args);
    return isSuccess ?? false;
  }
}
