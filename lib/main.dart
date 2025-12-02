import 'package:flutter/material.dart';
import 'screens/build_simulator_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toram Item Build Simulation',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF192127),
      ),
      home: const BuildSimulatorScreen(),
    );
  }
}
