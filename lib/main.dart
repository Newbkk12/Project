import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toram_build_simulator/screens/build_simulator_screen.dart';
import 'providers/theme_provider.dart';
import 'services/weapon_data_service.dart';
import 'services/auth_service.dart';
import 'services/build_service.dart';
import 'models/equipment_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final weaponService = WeaponDataService();
  await weaponService.initialize();

  // Initialize auth service
  final authService = AuthService();
  await authService.initialize();

  // Initialize build service
  final buildService = BuildService();
  await buildService.initialize();

  // Populate EquipmentData with weapon service data
  EquipmentData.loadFromWeaponService(weaponService);

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
