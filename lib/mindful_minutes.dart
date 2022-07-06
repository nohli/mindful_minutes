library mindful_minutes;

import 'package:flutter/services.dart';

class MindfulMinutesPlugin {
  static const MethodChannel _channel = MethodChannel('mindful_minutes');

  Future<bool> checkPermission() async {
    return await _channel.invokeMethod<bool?>('checkPermission') ?? false;
  }

  Future<bool> requestPermission() async {
    return await _channel.invokeMethod<bool?>('requestPermission') ?? false;
  }

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
