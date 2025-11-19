import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindful_minutes_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('mindful_minutes');
  late TestDefaultBinaryMessenger messenger;
  bool savedMindfulMinute = false;

  setUp(() {
    savedMindfulMinute = false;
    messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'checkPermission':
          return true;
        case 'requestPermission':
          return true;
        case 'saveMindfulMinutes':
          final Map<dynamic, dynamic> rawArgs =
              call.arguments as Map<dynamic, dynamic>;
          final Map<String, int> args = rawArgs.map(
            (key, value) => MapEntry(key as String, value as int),
          );
          expect(args, contains('startTime'));
          expect(args, contains('endTime'));
          expect(args['endTime']! - args['startTime']!,
              greaterThanOrEqualTo(const Duration(minutes: 1).inMilliseconds));
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

  testWidgets('saves mindful minute when the CTA is pressed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Save one mindful minute'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(savedMindfulMinute, isTrue);
  });
}
