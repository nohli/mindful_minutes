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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _saveMindfulMinutes,
            child: const Text('Save one mindful minute'),
          ),
        ),
      ),
    );
  }

  Future<void> _saveMindfulMinutes() async {
    final plugin = MindfulMinutesPlugin();

    final bool hasPermission = await plugin.checkPermission();
    if (!hasPermission) {
      final bool isPermissionGranted = await plugin.requestPermission();
      if (isPermissionGranted) {
        final startTime = DateTime.now();
        final endTime = startTime.subtract(const Duration(minutes: 1));
        await plugin.writeMindfulMinutes(startTime, endTime);
      }
    }
  }
}
