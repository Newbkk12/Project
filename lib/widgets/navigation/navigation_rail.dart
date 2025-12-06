// แถบนำทางด้านข้างที่กำหนดเองสำหรับหน้าเว็บแอป
import 'package:flutter/material.dart';
import '../../screens/build_simulator_screen.dart';
import '../../screens/database_screen.dart';

class CustomNavigationRail extends StatefulWidget {
  final Function(int)? onDestinationSelected;
  final int? initialIndex;

  const CustomNavigationRail({
    super.key,
    this.onDestinationSelected,
    this.initialIndex,
  });

  @override
  State<CustomNavigationRail> createState() => CustomNavigationRailState();
}

class CustomNavigationRailState extends State<CustomNavigationRail> {
  late int _selectedIndex;
  bool _isExtended = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
  }

  // Public API: allow external toggling (e.g. from AppBar)
  void toggleExtended() => setState(() => _isExtended = !_isExtended);

  void _handleDestinationSelected(int index) {
    setState(() => _selectedIndex = index);

    if (widget.onDestinationSelected != null) {
      widget.onDestinationSelected!(index);
    } else {
      // Default navigation behavior with smooth transition
      if (index == 0) {
        // Navigate to Build Simulator
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
      } else if (index == 1) {
        // Navigate to Database
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
