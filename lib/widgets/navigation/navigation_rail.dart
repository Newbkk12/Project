import 'package:flutter/material.dart';

class CustomNavigationRail extends StatelessWidget {
  const CustomNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: const Color(0xFF313440),
      selectedIndex: 0,
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
      indicatorColor: Colors.cyanAccent.withOpacity(0.3),
      onDestinationSelected: (i) {},
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text("Build"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.save_outlined),
          selectedIcon: Icon(Icons.save),
          label: Text("Saved"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.folder_open_outlined),
          selectedIcon: Icon(Icons.folder_open),
          label: Text("Load"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text("Settings"),
        ),
      ],
    );
  }
}