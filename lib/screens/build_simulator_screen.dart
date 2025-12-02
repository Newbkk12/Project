import 'package:flutter/material.dart';

import '../widgets/build_page/character_stats_section.dart';
import '../widgets/build_page/weapon_config_section.dart';
import '../widgets/build_page/stats_summary_section.dart';
import '../widgets/build_page/special_stats_section.dart';
import '../widgets/navigation/navigation_rail.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

class BuildSimulatorScreen extends StatelessWidget {
  const BuildSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF119D7C),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 32),
            SizedBox(width: 12),
            Text("Toram Item Build Simulation",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Stack(
        children: [
          isTablet
              ? Row(
            children: [
              const CustomNavigationRail(),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: _buildContent()),
            ],
          )
              : _buildContent(),
        ],
      ),
      bottomNavigationBar: isTablet ? null : const CustomBottomNavigationBar(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF383B68).withOpacity(0.24),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // หัวข้อ
            const Text(
              "Equipment Configuration",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // เนื้อหาหลัก - 3 คอลัมน์
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1000) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // คอลัมน์ 1: ซ้ายสุด - Character Stats + Main Weapon
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

                        // คอลัมน์ 2: ตรงกลาง (แคบ) - Stats Summary + Special Stats
                        Expanded(
                          flex: 3, // แคบที่สุดในสามช่อง
                          child: Column(
                            children: const [
                              StatsSummarySection(),
                              SizedBox(height: 24),
                              SpecialStatsSection(),
                            ],
                          ),
                        ),

                        const SizedBox(width: 32),

                        // คอลัมน์ 3: ขวาสุด - ว่างไว้ (กว้างและยาวที่สุด)
                        Expanded(
                          flex: 6, // กว้างสุด ~50% ของหน้าจอ
                          child: Column(
                            children: [
                              // ตอนนี้ยังว่าง หรือใส่ Text ชั่วคราวก็ได้
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.build, size: 48, color: Colors.cyanAccent),
                                    SizedBox(height: 16),
                                    Text(
                                      "Equipment Slot\n(Armor / AddGear / Ring / etc.)",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(), // ดึงให้คอลัมน์นี้ยาวลงถึงล่างสุด
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // มือถือ / หน้าจอเล็ก → เรียงจากบนลงล่างตามลำดับเดิม
                  return const SingleChildScrollView(
                    child: Column(
                      children: [
                        CharacterStatsSection(),
                        SizedBox(height: 24),
                        WeaponConfigSection(),
                        SizedBox(height: 32),
                        StatsSummarySection(),
                        SizedBox(height: 24),
                        SpecialStatsSection(),
                        SizedBox(height: 32),
                        // พื้นที่สำหรับ Equipment ในอนาคต
                        Text("Equipment Slot (จะมาเพิ่มตรงนี้)", style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}