import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mindful_minutes/mindful_minutes.dart';

void main() => runApp(const MyApp());

///
class MyApp extends StatefulWidget {
  ///
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = MindfulMinutesPlugin();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _saveMindfulMinute,
            child: const Text('Save one mindful minute'),
          ),
        ),
      ),
    );
  }

  Future<void> _saveMindfulMinute() async {
    try {
      bool hasPermission = await _plugin.checkPermission();
      if (!hasPermission) hasPermission = await _plugin.requestPermission();

      if (hasPermission) {
        final endTime = DateTime.now();
        final startTime = endTime.subtract(const Duration(minutes: 1));
        await _plugin.writeMindfulMinutes(startTime, endTime);
      } else {
        // Show a hint to enable the Apple Health permission in system settings
      }
    } catch (error) {
      // Show an error message

      if (kDebugMode) rethrow;
    }
  }
}
