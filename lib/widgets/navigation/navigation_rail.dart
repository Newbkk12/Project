// แถบนำทางด้านข้างที่กำหนดเองสำหรับหน้าเว็บแอป
import 'package:flutter/material.dart';
import '../../screens/database_screen.dart';

class CustomNavigationRail extends StatefulWidget {
  final Function(int)? onDestinationSelected;

  const CustomNavigationRail({super.key, this.onDestinationSelected});

  @override
  State<CustomNavigationRail> createState() => CustomNavigationRailState();
}

class CustomNavigationRailState extends State<CustomNavigationRail> {
  int _selectedIndex = 0;
  bool _isExtended = false;

  // Public API: allow external toggling (e.g. from AppBar)
  void toggleExtended() => setState(() => _isExtended = !_isExtended);

  void _handleDestinationSelected(int index) {
    setState(() => _selectedIndex = index);

    if (widget.onDestinationSelected != null) {
      widget.onDestinationSelected!(index);
    } else {
      // Default navigation behavior
      if (index == 1) {
        // Navigate to Database
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DatabaseScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: const Color(0xFF313440),
      selectedIndex: _selectedIndex,
      onDestinationSelected: _handleDestinationSelected,
      extended: _isExtended,
      minWidth: 60,
      minExtendedWidth: 155,

      // ฟอนต์ เปลี่ยนตามสถานะ
      selectedLabelTextStyle: TextStyle(
        color: Colors.cyanAccent,
        fontWeight: FontWeight.bold,
        fontSize: _isExtended ? 15 : 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Colors.white70,
        fontSize: _isExtended ? 14 : 11,
      ),

      indicatorColor: const Color.fromRGBO(24, 255, 255, 0.3),
      useIndicator: true,

      // ────────────────────────────────
      // เมนูหลัก
      // ────────────────────────────────
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.build_outlined),
          selectedIcon: Icon(Icons.build),
          label: Text("Build"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.folder_open_outlined),
          selectedIcon: Icon(Icons.folder_open),
          label: Text("Database"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text("Settings"),
        ),
      ],

      // ────────────────────────────────
      // ปุ่มด้านล่าง: Login
      // ────────────────────────────────
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              icon: const Icon(Icons.account_circle,
                  color: Colors.white70, size: 28),
              tooltip: 'Login',
              onPressed: () {
                // TODO: Navigate to login screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
