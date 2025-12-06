//แถบการนำทางด้านล่างที่กำหนดเองสำหรับแอปพลิเคชัน

import 'package:flutter/material.dart';
import '../../screens/database_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF313440),
      selectedItemColor: Colors.cyanAccent,
      unselectedItemColor: Colors.white70,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      currentIndex: 0,
      onTap: (i) {
        if (i == 1) {
          // Navigate to Database
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DatabaseScreen()),
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
