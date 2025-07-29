import 'package:catch_table/screens/queue_registration.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catch Table',
      debugShowCheckedModeBanner: false,
      home: const QueueRegistrationScreen(),
    );
  }
}
