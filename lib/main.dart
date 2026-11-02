import 'package:flutter/material.dart';
import 'config/app_constants.dart';

void main() {
  runApp(const DompetkuApp());
}

class DompetkuApp extends StatelessWidget {
  const DompetkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text(AppConstants.appName)),
        body: const Center(
          child: Text('${AppConstants.studentId} - ${AppConstants.studentName}'),
        ),
      ),
    );
  }
}