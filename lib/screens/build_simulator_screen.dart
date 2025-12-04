import 'package:flutter/material.dart';

import '../widgets/build_page/character_stats_section.dart';
import '../widgets/build_page/weapon_config_section.dart';
import '../widgets/build_page/stats_summary_section.dart';
import '../widgets/build_page/special_stats_section.dart';
import '../widgets/navigation/navigation_rail.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';
import '../widgets/navigation/app_drawer.dart';

class BuildSimulatorScreen extends StatelessWidget {
  const BuildSimulatorScreen({super.key});

  // กำหนด breakpoint ชัดเจน
  static const double _mobileMaxWidth = 700;
  static const double _tabletMinWidth = 700;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isMobile = width < _mobileMaxWidth;
        final bool isDesktop = width >= _tabletMinWidth;

        final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
        final navRailKey = GlobalKey<CustomNavigationRailState>();

        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: const Color(0xFF119D7C),
            title: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Colors.cyanAccent,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isMobile ? "Toram Build" : "Toram Item Build Simulation",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // แสดง hamburger: ซ้ายสำหรับเดสก์ท็อป, ขวาสำหรับมือถือ
            leading: isDesktop
                ? IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => navRailKey.currentState?.toggleExtended(),
                  )
                : null,
            actions: isMobile
                ? [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () =>
                          scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ]
                : null,
          ),

          // มือถือ: มี Drawer (3 ขีดขวา) | เดสก์ท็อป: ไม่มี
          endDrawer: isMobile ? const AppDrawer() : null,

          // ตัว body แยกตามขนาดหน้าจอ
          body: Row(
            children: [
              // เดสก์ท็อป/แท็บเล็ต: แสดง NavigationRail ด้านซ้าย
              if (isDesktop) ...[
                CustomNavigationRail(key: navRailKey),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: Colors.white10,
                ),
              ],

              // เนื้อหาหลัก
              Expanded(
                child: _buildMainContent(isMobile: isMobile, width: width),
              ),
            ],
          ),

          // มือถือ: แสดง BottomNavigationBar | เดสก์ท็อป: ไม่มี
          bottomNavigationBar: isMobile
              ? const CustomBottomNavigationBar()
              : null,
        );
      },
    );
  }

  Widget _buildMainContent({required bool isMobile, required double width}) {
    // สำคัญมาก: อย่าใช้ Padding(all: 24) แบบเดิมเด็ดขาด!
    // เปลี่ยนเป็น SafeArea + Padding เฉพาะด้านขวา/ล่าง แทน

    return SafeArea(
      left:
          false, // สำคัญ! อย่าให้ SafeArea ทับซ้าย → ปล่อยให้ Rail อยู่เต็มพื้นที่
      child: Padding(
        // ใช้ padding เฉพาะด้านที่ไม่ทับ Rail (ซ้าย)
        padding: EdgeInsets.only(
          //left: isDesktop ? 0 : 24, // เดสก์ท็อป = 0 (ไม่ทับ Rail), มือถือ = 24
          top: 24,
          right: 24,
          bottom: 24,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF383B68).withOpacity(0.24),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Equipment Configuration",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: isMobile
                    ? SingleChildScrollView(child: _buildMobileLayout())
                    : _buildDesktopLayout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Layout สำหรับมือถือ (เรียงจากบนลงล่าง)
  Widget _buildMobileLayout() {
    return Column(
      children: const [
        CharacterStatsSection(),
        SizedBox(height: 24),
        WeaponConfigSection(),
        SizedBox(height: 32),
        StatsSummarySection(),
        SizedBox(height: 24),
        SpecialStatsSection(),
        SizedBox(height: 32),
        SizedBox(height: 100),
      ],
    );
  }

  // Layout สำหรับเดสก์ท็อป (3 คอลัมน์)
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: const [
              CharacterStatsSection(),
              SizedBox(height: 24),
              WeaponConfigSection(),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 3,
          child: Column(
            children: const [
              StatsSummarySection(),
              SizedBox(height: 24),
              SpecialStatsSection(),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 6,
          child: Column(children: [_EquipmentPlaceholder(), const Spacer()]),
        ),
      ],
    );
  }

  // Widget ตัวอย่างสำหรับ Equipment Slot (แชร์ทั้ง 2 layout)
  static Widget _EquipmentPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.build, size: 56, color: Colors.cyanAccent),
          SizedBox(height: 16),
          Text(
            "Equipment Slot\n(Armor / AddGear / Ring / etc.)",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
