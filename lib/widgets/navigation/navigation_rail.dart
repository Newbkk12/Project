// แถบนำทางด้านข้างที่กำหนดเองสำหรับหน้าเว็บแอป
import 'package:flutter/material.dart';

class CustomNavigationRail extends StatefulWidget {
  const CustomNavigationRail({super.key});

  @override
  State<CustomNavigationRail> createState() => CustomNavigationRailState();
}

class CustomNavigationRailState extends State<CustomNavigationRail> {
  int _selectedIndex = 0;
  bool _isExtended = false;

  // Public API: allow external toggling (e.g. from AppBar)
  void toggleExtended() => setState(() => _isExtended = !_isExtended);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: const Color(0xFF313440),
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      extended: _isExtended,
      minWidth: 72,
      minExtendedWidth: 180,

      // ฟอนต์ + ไอคอน เปลี่ยนตามสถานะ
      selectedIconTheme: IconThemeData(
        color: Colors.cyanAccent,
        size: _isExtended ? 28 : 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.white70,
        size: _isExtended ? 26 : 24,
      ),
      selectedLabelTextStyle: TextStyle(
        color: Colors.cyanAccent,
        fontWeight: FontWeight.bold,
        fontSize: _isExtended ? 15 : 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Colors.white70,
        fontSize: _isExtended ? 14 : 11,
      ),

      indicatorColor: Colors.cyanAccent.withOpacity(0.3),
      useIndicator: true,

      // ────────────────────────────────
      // ส่วนสำคัญ: ย้ายแถบ 3 ขีดขึ้นด้านบนสุด!
      // ────────────────────────────────
      leading: Column(
        children: [
          // 2. โลโก้ + ชื่อแอป (อยู่ถัดลงมา)
          if (_isExtended)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Toram Build\nSimulator",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),

          // เส้นแบ่ง (เฉพาะตอนขยาย)
          if (_isExtended)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Divider(color: Colors.white24, height: 32),
            ),
        ],
      ),

      // ────────────────────────────────
      // เมนูหลัก
      // ────────────────────────────────
      destinations: const [
        NavigationRailDestination(
          icon: Tooltip(message: "Build", child: Icon(Icons.build_outlined)),
          selectedIcon: Tooltip(message: "Build", child: Icon(Icons.build)),
          label: Text("Build"),
        ),
        NavigationRailDestination(
          icon: Tooltip(
            message: "Saved Builds",
            child: Icon(Icons.bookmark_border),
          ),
          selectedIcon: Tooltip(
            message: "Saved Builds",
            child: Icon(Icons.bookmark),
          ),
          label: Text("Saved Builds"),
        ),
        NavigationRailDestination(
          icon: Tooltip(
            message: "Load Build",
            child: Icon(Icons.folder_open_outlined),
          ),
          selectedIcon: Tooltip(
            message: "Load Build",
            child: Icon(Icons.folder_open),
          ),
          label: Text("Load Build"),
        ),
        NavigationRailDestination(
          icon: Tooltip(
            message: "Settings",
            child: Icon(Icons.settings_outlined),
          ),
          selectedIcon: Tooltip(
            message: "Settings",
            child: Icon(Icons.settings),
          ),
          label: Text("Settings"),
        ),
      ],

      // ลบ trailing ออก เพราะเราใส่โลโก้ไว้ใน leading แล้ว
      trailing: const SizedBox(height: 16),
    );
  }
}
