import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindful_minutes/mindful_minutes.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // XCTest requests semantics before the test body, so establish that baseline before Flutter's leak check.
  binding.platformDispatcher.semanticsEnabledTestValue = true;

  testWidgets('reports the native permission status on iOS', (WidgetTester tester) async {
    expect(defaultTargetPlatform, TargetPlatform.iOS);

    const plugin = MindfulMinutesPlugin();
    final hasPermission = await plugin.checkPermission();

    expect(hasPermission, isA<bool>());
  }, semanticsEnabled: false);
}
