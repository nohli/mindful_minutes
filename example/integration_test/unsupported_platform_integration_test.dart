import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindful_minutes/mindful_minutes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const plugin = MindfulMinutesPlugin();
  final startTime = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  final endTime = startTime.add(const Duration(minutes: 1));

  test(
    'returns false without throwing on Android',
    () async {
      expect(await plugin.checkPermission(), false);
      expect(await plugin.requestPermission(), false);
      expect(await plugin.writeMindfulMinutes(startTime, endTime), false);
    },
    skip: defaultTargetPlatform != TargetPlatform.android,
  );
}
