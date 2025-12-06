import 'package:flutter/material.dart';

import 'package:toram_build_simulator/widgets/build_page/character_stats_section.dart';
import 'package:toram_build_simulator/widgets/build_page/weapon_config_section.dart';
import 'package:toram_build_simulator/widgets/build_page/stats_summary_section.dart';
import 'package:toram_build_simulator/widgets/build_page/special_stats_section.dart';
import 'package:toram_build_simulator/widgets/navigation/navigation_rail.dart';
import 'package:toram_build_simulator/widgets/navigation/bottom_navigation_bar.dart';
import 'package:toram_build_simulator/widgets/navigation/app_drawer.dart';

/// =================================================================
/// BuildSimulatorScreen (เดิมทั้งหมด ไม่มีลบ)
/// =================================================================

class BuildSimulatorScreen extends StatelessWidget {
  const BuildSimulatorScreen({super.key});

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
                const Icon(Icons.auto_awesome,
                    color: Colors.cyanAccent, size: 32),
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
                    )
                  ]
                : null,
          ),
          endDrawer: isMobile ? const AppDrawer() : null,
          body: Row(
            children: [
              if (isDesktop) ...[
                CustomNavigationRail(key: navRailKey),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: Color.fromARGB(26, 240, 237, 237),
                ),
                const Padding(padding: EdgeInsets.only(left: 27)),
              ],
              Expanded(
                child: _buildMainContent(isMobile: isMobile, width: width),
              ),
            ],
          ),
          bottomNavigationBar:
              isMobile ? const CustomBottomNavigationBar() : null,
        );
      },
    );
  }

  Widget _buildMainContent({required bool isMobile, required double width}) {
    return SafeArea(
      left: false,
      child: Padding(
        padding: EdgeInsets.only(
          top: 24,
          right: 24,
          bottom: 24,
          left: isMobile ? 24 : 0,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(56, 59, 104, 0.24),
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
          child: Column(
            children: const [
              _EquipmentPlaceholder(),
              Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------
/// Equipment Placeholder ตัวแรก (คงไว้)
//  BuildSimulatorScreen + YourWidget จะใช้ตัวนี้ร่วมกัน
/// ------------------------------------------------------
class _EquipmentPlaceholder extends StatelessWidget {
  const _EquipmentPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final out = {
      'ATK': '-',
      'MATK': '-',
      'HP': '-',
      'CritRate': '-',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(24, 255, 255, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            "Stats Summary",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 16),

          // Rows
          Row(children: [
            const Expanded(
                child: Text('ATK', style: TextStyle(color: Colors.white70))),
            Text(out['ATK'].toString(),
                style: const TextStyle(color: Colors.white)),
          ]),
          const SizedBox(height: 6),

          Row(children: [
            const Expanded(
                child: Text('MATK', style: TextStyle(color: Colors.white70))),
            Text(out['MATK'].toString(),
                style: const TextStyle(color: Colors.white)),
          ]),
          const SizedBox(height: 6),

          Row(children: [
            const Expanded(
                child: Text('HP', style: TextStyle(color: Colors.white70))),
            Text(out['HP'].toString(),
                style: const TextStyle(color: Colors.white)),
          ]),
          const SizedBox(height: 6),

          Row(children: [
            const Expanded(
                child:
                    Text('Crit Rate', style: TextStyle(color: Colors.white70))),
            Text(out['CritRate'].toString(),
                style: const TextStyle(color: Colors.white)),
          ]),

          const SizedBox(height: 20),

          // Export Button
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.share),
            label: const Text('Export JSON'),
          ),
        ],
      ),
    );
  }
}
