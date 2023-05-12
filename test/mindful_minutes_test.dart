import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful_minutes/mindful_minutes.dart';

void main() {
  final plugin = MindfulMinutesPlugin();
  const channel = MethodChannel('mindful_minutes');

  TestWidgetsFlutterBinding.ensureInitialized();

  void setMethodCallHandlerToReturnValue(bool? value) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      final method = methodCall.method;
      switch (method) {
        case 'checkPermission':
          return value;
        case 'requestPermission':
          return value;
        case 'writeMindfulMinutes':
          return value;
        default:
          throw UnimplementedError('$method not implemented');
      }
    });
  }

  tearDown(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (null)));

  group('method call handler returns true', () {
    setUp(() => setMethodCallHandlerToReturnValue(true));

    test('checkPermission returns correct value of method channel', () async {
      expect(await plugin.checkPermission(), true);
    });

    test('requestPermission returns correct value of method channel', () async {
      expect(await plugin.requestPermission(), true);
    });

    test('saveMindfulMinutes returns correct value of method channel',
        () async {
      expect(await plugin.requestPermission(), true);
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

    test('saveMindfulMinutes returns correct value of method channel',
        () async {
      expect(await plugin.requestPermission(), false);
    });
  });

  group('method call handlers returns null', () {
    setUp(() => setMethodCallHandlerToReturnValue(null));

    test('checkPermission returns false if method call returns null', () async {
      expect(await plugin.checkPermission(), false);
    });

    test('requestPermission returns false if method call returns null',
        () async {
      expect(await plugin.requestPermission(), false);
    });

    test('saveMindfulMinutes returns false if method call returns null',
        () async {
      expect(await plugin.requestPermission(), false);
    });
  });
}
