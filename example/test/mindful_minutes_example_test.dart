import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful_minutes_example/main.dart';

void main() {
  for (final granted in [false, true]) {
    testWidgets('permission request completion checks write authorization: $granted', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      var permissionChecks = 0;
      var saves = 0;
      const channel = MethodChannel('mindful_minutes');
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'checkPermission':
            permissionChecks++;
            return permissionChecks > 1 && granted;
          case 'requestPermission':
            return true;
          case 'saveMindfulMinutes':
            saves++;
            return true;
          default:
            throw UnimplementedError(call.method);
        }
      });
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
        messenger.setMockMethodCallHandler(channel, null);
      });
      try {
        await tester.pumpWidget(const MyApp());
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(permissionChecks, 2);
        expect(saves, granted ? 1 : 0);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('Displays text', (WidgetTester tester) async {
    const widget = MyApp();
    const text = 'Save one mindful minute';

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.text(text), findsOneWidget);
  });

  testWidgets('Can press button', (WidgetTester tester) async {
    const widget = MyApp();

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    final button = find.byType(ElevatedButton);
    await tester.tap(button);
  });
}
