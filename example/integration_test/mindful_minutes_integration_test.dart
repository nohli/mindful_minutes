import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindful_minutes/mindful_minutes.dart';
import 'package:mindful_minutes_example/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // XCTest requests semantics before the test body, so establish that baseline before Flutter's leak check.
  binding.platformDispatcher.semanticsEnabledTestValue = true;

  group('example flow', () {
    const channel = MethodChannel('mindful_minutes');
    late TestDefaultBinaryMessenger messenger;
    bool savedMindfulMinute = false;

    setUp(() {
      savedMindfulMinute = false;
      messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        switch (call.method) {
          case 'checkPermission':
            return true;
          case 'requestPermission':
            return true;
          case 'saveMindfulMinutes':
            final Map<dynamic, dynamic> rawArgs = call.arguments as Map<dynamic, dynamic>;
            final Map<String, int> args = rawArgs.map(
              (key, value) => MapEntry(key as String, value as int),
            );
            expect(args, contains('startTime'));
            expect(args, contains('endTime'));
            expect(
              args['endTime']! - args['startTime']!,
              greaterThanOrEqualTo(const Duration(minutes: 1).inMilliseconds),
            );
            savedMindfulMinute = true;
            return true;
          default:
            return null;
        }
      });
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
    });

    testWidgets('saves mindful minute when the CTA is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Save one mindful minute'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(savedMindfulMinute, isTrue);
    }, semanticsEnabled: false);
  });

  testWidgets('reports the native permission status on iOS', (WidgetTester tester) async {
    expect(defaultTargetPlatform, TargetPlatform.iOS);

    const plugin = MindfulMinutesPlugin();
    final hasPermission = await plugin.checkPermission();

    expect(hasPermission, isA<bool>());
  }, semanticsEnabled: false);
}
