//แถบการนำทางด้านล่างที่กำหนดเองสำหรับแอปพลิเคชัน

import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF313440),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: 0,
      onTap: (i) {},
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Build"),
        BottomNavigationBarItem(icon: Icon(Icons.save), label: "Save"),
        BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: "Load"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
