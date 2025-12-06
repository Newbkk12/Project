// แถบนำทางด้านข้างที่กำหนดเองสำหรับหน้าเว็บแอป
import 'package:flutter/material.dart';
import '../../screens/build_simulator_screen.dart';
import '../../screens/database_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/settings_screen.dart';
import '../../providers/theme_provider.dart';

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
      } else if (index == 2) {
        // Navigate to Settings
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SettingsScreen(),
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
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return NavigationRail(
      backgroundColor:
          customColors?.navigationBackground ?? const Color(0xFF313440),
      selectedIndex: _selectedIndex,
      onDestinationSelected: _handleDestinationSelected,
      extended: _isExtended,
      minWidth: 60,
      minExtendedWidth: 155,

      // ฟอนต์ เปลี่ยนตามสถานะ
      selectedLabelTextStyle: TextStyle(
        color: theme.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: _isExtended ? 15 : 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.black54,
        fontSize: _isExtended ? 14 : 11,
      ),

      indicatorColor: theme.primaryColor.withValues(alpha: 0.3),
      useIndicator: true,

      // ────────────────────────────────
      // เมนูหลัก
      // ────────────────────────────────
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.build_outlined,
              color: theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54),
          selectedIcon: Icon(Icons.build, color: theme.primaryColor),
          label: const Text("Build"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.folder_open_outlined,
              color: theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54),
          selectedIcon: Icon(Icons.folder_open, color: theme.primaryColor),
          label: const Text("Database"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined,
              color: theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54),
          selectedIcon: Icon(Icons.settings, color: theme.primaryColor),
          label: const Text("Settings"),
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
              icon: Icon(Icons.account_circle,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                  size: 28),
              tooltip: 'Login',
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const LoginScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 200),
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
