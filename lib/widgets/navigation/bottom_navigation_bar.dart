//แถบการนำทางด้านล่างที่กำหนดเองสำหรับแอปพลิเคชัน

import 'package:flutter/material.dart';
import '../../screens/build_simulator_screen.dart';
import '../../screens/database_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int? initialIndex;

  const CustomBottomNavigationBar({
    super.key,
    this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF313440),
      selectedItemColor: Colors.cyanAccent,
      unselectedItemColor: Colors.white70,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      currentIndex: initialIndex ?? 0,
      onTap: (i) {
        if (i == 0) {
          // Navigate to Build Simulator with smooth transition
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const BuildSimulatorScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 200),
            ),
          );
        } else if (i == 1) {
          // Navigate to Database with smooth transition
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const DatabaseScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 200),
            ),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.build), label: "Build"),
        BottomNavigationBarItem(
            icon: Icon(Icons.folder_open), label: "Database"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
