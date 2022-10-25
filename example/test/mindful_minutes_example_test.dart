import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindful_minutes_example/main.dart';

void main() {
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
