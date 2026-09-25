import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful_minutes/mindful_minutes.dart';

void main() {
  const plugin = MindfulMinutesPlugin();
  const channel = MethodChannel('mindful_minutes');

  TestWidgetsFlutterBinding.ensureInitialized();
  final startTime = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  final endTime = startTime.add(const Duration(minutes: 1));

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });

  void setMethodCallHandlerToReturnValue(bool? value) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall methodCall) async {
      final method = methodCall.method;
      switch (method) {
        case 'checkPermission':
          return value;
        case 'requestPermission':
          return value;
        case 'saveMindfulMinutes':
          return value;
        default:
          throw UnimplementedError('$method not implemented');
      }
    });
  }

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('method call handler returns true', () {
    setUp(() => setMethodCallHandlerToReturnValue(true));

    test('checkPermission returns correct value of method channel', () async {
      expect(await plugin.checkPermission(), true);
    });

    test('requestPermission returns correct value of method channel', () async {
      expect(await plugin.requestPermission(), true);
    });

    test('saveMindfulMinutes returns correct value of method channel', () async {
      expect(await plugin.writeMindfulMinutes(startTime, endTime), true);
    });
  });

  group('method call handler returns false', () {
    setUp(() => setMethodCallHandlerToReturnValue(false));

    test('checkPermission returns correct value of method channel', () async {
      expect(await plugin.checkPermission(), false);
    });

    test('requestPermission returns correct value of method channel', () async {
      expect(await plugin.requestPermission(), false);
    });

    test('saveMindfulMinutes returns correct value of method channel', () async {
      expect(await plugin.writeMindfulMinutes(startTime, endTime), false);
    });
  });

  group('method call handlers returns null', () {
    setUp(() => setMethodCallHandlerToReturnValue(null));

    test('checkPermission returns false if method call returns null', () async {
      expect(await plugin.checkPermission(), false);
    });

    test('requestPermission returns false if method call returns null', () async {
      expect(await plugin.requestPermission(), false);
    });

    test('saveMindfulMinutes returns false if method call returns null', () async {
      expect(await plugin.writeMindfulMinutes(startTime, endTime), false);
    });
  });

  group('Android', () {
    var channelCalls = 0;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      channelCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (MethodCall methodCall) async {
        channelCalls += 1;
        return true;
      });
    });

    test('checkPermission returns false without a channel call', () async {
      expect(await plugin.checkPermission(), false);
      expect(channelCalls, 0);
    });

    test('requestPermission returns false without a channel call', () async {
      expect(await plugin.requestPermission(), false);
      expect(channelCalls, 0);
    });

    test('writeMindfulMinutes returns false without a channel call', () async {
      expect(await plugin.writeMindfulMinutes(startTime, endTime), false);
      expect(channelCalls, 0);
    });
  });
}
