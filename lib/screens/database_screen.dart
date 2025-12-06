import 'package:flutter/material.dart';
import '../models/equipment_data.dart';
import '../widgets/navigation/navigation_rail.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<CustomNavigationRailState> _navRailKey =
      GlobalKey<CustomNavigationRailState>();

  final List<String> _categories = [
    'All',
    'Weapon',
    'Sub Weapon',
    'Body Armor',
    'Additional Gear',
    'Special Gear',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EquipmentItem> _getFilteredItems() {
    List<EquipmentItem> items = List.from(EquipmentData.items);

    // Filter by category
    if (_selectedCategory != 'All') {
      items = items.where((item) {
        return _getCategoryFromType(item.type) == _selectedCategory;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort by name
    items.sort((a, b) => a.name.compareTo(b.name));

    return items;
  }

  String _getCategoryFromType(EquipmentType type) {
    switch (type) {
      case EquipmentType.mainWeapon:
        return 'Weapon';
      case EquipmentType.subWeapon:
        return 'Sub Weapon';
      case EquipmentType.armor:
        return 'Body Armor';
      case EquipmentType.helmet:
        return 'Additional Gear';
      case EquipmentType.ring:
        return 'Special Gear';
    }
  }

  String _getTypeDisplayName(EquipmentType type) {
    switch (type) {
      case EquipmentType.mainWeapon:
        return 'Main Weapon';
      case EquipmentType.subWeapon:
        return 'Sub Weapon';
      case EquipmentType.armor:
        return 'Body Armor';
      case EquipmentType.helmet:
        return 'Additional Gear';
      case EquipmentType.ring:
        return 'Special Gear';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;

        Widget body;
        if (isWide) {
          // Desktop: NavigationRail on left
          body = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNavigationRail(key: _navRailKey, initialIndex: 1),
              Expanded(
                child: _buildDatabaseContent(filteredItems),
              ),
            ],
          );
        } else {
          // Mobile: only show content
          body = _buildDatabaseContent(filteredItems);
        }

        return Scaffold(
          backgroundColor: const Color(0xFF192127),
          appBar: _buildHeader(isWide),
          body: body,
          bottomNavigationBar:
              isWide ? null : const CustomBottomNavigationBar(initialIndex: 1),
        );
      },
    );
  }

  PreferredSizeWidget _buildHeader(bool isWide) {
    return AppBar(
      backgroundColor: const Color(0xFF10A37F),
      elevation: 4,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            if (isWide)
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _navRailKey.currentState?.toggleExtended();
                },
                tooltip: 'Menu',
              ),
            if (isWide) const SizedBox(width: 8),
            const Image(
              image: AssetImage('assets/icon/Logo.png'),
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'Toram Online Database',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseContent(List<EquipmentItem> filteredItems) {
    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF10A37F)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF313440),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF10A37F), width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              // Category filter
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: const Color(0xFF313440),
                        selectedColor: const Color(0xFF10A37F),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Results count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            '${filteredItems.length} items found',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        // Items list
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No items found',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _buildItemCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildItemCard(EquipmentItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF10A37F).withValues(alpha: 0.3),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: _buildItemIcon(item.type),
        title: Text(
          item.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _getTypeDisplayName(item.type),
            style: const TextStyle(
              color: Color(0xFF10A37F),
              fontSize: 13,
            ),
          ),
        ),
        iconColor: const Color(0xFF10A37F),
        collapsedIconColor: Colors.white70,
        children: [
          _buildStatsTable(item),
        ],
      ),
    );
  }

  Widget _buildItemIcon(EquipmentType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case EquipmentType.mainWeapon:
        iconData = Icons.gavel;
        iconColor = const Color(0xFFFF6B6B);
        break;
      case EquipmentType.subWeapon:
        iconData = Icons.shield;
        iconColor = const Color(0xFF4ECDC4);
        break;
      case EquipmentType.armor:
        iconData = Icons.shield_outlined;
        iconColor = const Color(0xFF95E1D3);
        break;
      case EquipmentType.helmet:
        iconData = Icons.sports_motorsports;
        iconColor = const Color(0xFFFECA57);
        break;
      case EquipmentType.ring:
        iconData = Icons.circle_outlined;
        iconColor = const Color(0xFFEE5A6F);
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 28,
      ),
    );
  }

  Widget _buildStatsTable(EquipmentItem item) {
    final stats = <MapEntry<String, String>>[];

    if (item.atk > 0) stats.add(MapEntry('ATK', '+${item.atk}'));
    if (item.matk > 0) stats.add(MapEntry('MATK', '+${item.matk}'));
    if (item.def > 0) stats.add(MapEntry('DEF', '+${item.def}'));
    if (item.mdef > 0) stats.add(MapEntry('MDEF', '+${item.mdef}'));
    if (item.str > 0) stats.add(MapEntry('STR', '+${item.str}'));
    if (item.dex > 0) stats.add(MapEntry('DEX', '+${item.dex}'));
    if (item.intStat > 0) stats.add(MapEntry('INT', '+${item.intStat}'));
    if (item.agi > 0) stats.add(MapEntry('AGI', '+${item.agi}'));
    if (item.vit > 0) stats.add(MapEntry('VIT', '+${item.vit}'));
    if (item.aspd > 0) stats.add(MapEntry('ASPD', '+${item.aspd}'));
    if (item.critRate > 0)
      stats.add(MapEntry('Critical Rate', '+${item.critRate}%'));
    if (item.accuracy > 0)
      stats.add(MapEntry('Accuracy', '+${item.accuracy}%'));
    if (item.stability > 0)
      stats.add(MapEntry('Stability', '+${item.stability}%'));
    if (item.physicalPierce > 0)
      stats.add(MapEntry('Physical Pierce', '+${item.physicalPierce}%'));
    if (item.elementPierce > 0)
      stats.add(MapEntry('Element Pierce', '+${item.elementPierce}%'));
    if (item.hp > 0) stats.add(MapEntry('HP', '+${item.hp}'));
    if (item.mp > 0) stats.add(MapEntry('MP', '+${item.mp}'));

    if (stats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No stats available',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF313440).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: stats.map((stat) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0x22FFFFFF), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stat.key,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                Text(
                  stat.value,
                  style: const TextStyle(
                    color: Color(0xFF10A37F),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
