import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/build_simulator_screen.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Toram Build Simulator',
          scrollBehavior: NoGlowScrollBehavior(),
          theme: themeProvider.getThemeData(),
          home: const BuildSimulatorScreen(),
        );
      },
    );
  }
}

// เพิ่ม class นี้ไว้ใน main.dart หรือไฟล์ utils ก็ได้
class NoGlowScrollBehavior extends MaterialScrollBehavior {
  // ปิด glow ทั้งหมด (ขาว/น้ำเงิน/ทุกสี)
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  // ปิดการเด้งย้วยแบบ iOS (ถ้าอยากให้ scroll แน่น ๆ แบบ Android)
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  // รองรับทั้ง mouse และ touch
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
