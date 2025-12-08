import 'package:flutter/material.dart';
import '../models/equipment_data.dart';
import '../services/weapon_data_service.dart';
import '../widgets/navigation/navigation_rail.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen>
    with AutomaticKeepAliveClientMixin {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'name'; // name, atk, matk, def
  bool _sortAscending = true;
  bool _compactView = false;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<CustomNavigationRailState> _navRailKey =
      GlobalKey<CustomNavigationRailState>();
  final WeaponDataService _weaponService = WeaponDataService();
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps, 'count': 0},
    {'name': 'Weapon', 'icon': Icons.gavel, 'count': 0},
    {'name': 'Sub Weapon', 'icon': Icons.shield, 'count': 0},
    {'name': 'Body Armor', 'icon': Icons.shield_outlined, 'count': 0},
    {'name': 'Additional Gear', 'icon': Icons.sports_motorsports, 'count': 0},
    {'name': 'Special Gear', 'icon': Icons.circle_outlined, 'count': 0},
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _weaponService.initialize();
    _updateCategoryCounts();
    setState(() {
      _isLoading = false;
    });
  }

  void _updateCategoryCounts() {
    for (var cat in _categories) {
      final name = cat['name'] as String;
      final items = _weaponService.search(
        category: name == 'All' ? null : name,
        onlyWithStats: true,
      );
      cat['count'] = items.length;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Weapon> _getFilteredItems() {
    var results = _weaponService.search(
      query: _searchQuery.isEmpty ? null : _searchQuery,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      onlyWithStats: true,
    );

    // Sort results
    results.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'atk':
          comparison = b.baseAtk.compareTo(a.baseAtk);
          break;
        case 'matk':
          comparison = b.baseMatk.compareTo(a.baseMatk);
          break;
        case 'def':
          comparison = b.baseDef.compareTo(a.baseDef);
          break;
        case 'name':
        default:
          comparison = a.displayName.compareTo(b.displayName);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return results;
  }

  String _getTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case '1h sword':
      case 'one_handed_sword':
        return '1H Sword';
      case '2h sword':
      case 'two_handed_sword':
        return '2H Sword';
      case 'bow':
        return 'Bow';
      case 'bowgun':
        return 'Bowgun';
      case 'dagger':
        return 'Dagger';
      case 'halberd':
        return 'Halberd';
      case 'katana':
        return 'Katana';
      case 'knuckles':
        return 'Knuckles';
      case 'magic_device':
        return 'Magic Device';
      case 'ninjutsu_scroll':
        return 'Ninjutsu Scroll';
      case 'shield':
        return 'Shield';
      case 'staff':
        return 'Staff';
      case 'arrow':
        return 'Arrow';
      case 'armor':
        return 'Body Armor';
      case 'additional':
        return 'Additional Gear';
      case 'special':
        return 'Special Gear';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final filteredItems = _getFilteredItems();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;

        Widget body;
        if (_isLoading) {
          body = const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF10A37F),
            ),
          );
        } else if (isWide) {
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

  Widget _buildDatabaseContent(List<Weapon> filteredItems) {
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
              // Category filter with icons and counts
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final categoryName = category['name'] as String;
                    final categoryIcon = category['icon'] as IconData;
                    final categoryCount = category['count'] as int;
                    final isSelected = categoryName == _selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(
                          categoryIcon,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(categoryName),
                            if (categoryCount > 0)
                              Text(
                                '($categoryCount)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.white54,
                                ),
                              ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = categoryName;
                          });
                        },
                        backgroundColor: const Color(0xFF313440),
                        selectedColor: const Color(0xFF10A37F),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Sort and View options
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF313440),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: const Color(0xFF313440),
                        icon: const Icon(Icons.sort,
                            color: Color(0xFF10A37F), size: 20),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        items: const [
                          DropdownMenuItem(
                              value: 'name', child: Text('Sort: Name')),
                          DropdownMenuItem(
                              value: 'atk', child: Text('Sort: ATK')),
                          DropdownMenuItem(
                              value: 'matk', child: Text('Sort: MATK')),
                          DropdownMenuItem(
                              value: 'def', child: Text('Sort: DEF')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: const Color(0xFF10A37F),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                    tooltip: _sortAscending ? 'Ascending' : 'Descending',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF313440),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _compactView ? Icons.view_list : Icons.view_compact,
                      color: const Color(0xFF10A37F),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _compactView = !_compactView;
                      });
                    },
                    tooltip: _compactView ? 'Detailed View' : 'Compact View',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF313440),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
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
                    return _compactView
                        ? _buildCompactItemCard(item, index)
                        : _buildDetailedItemCard(item, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDetailedItemCard(Weapon item, int index) {
    return Card(
      key: ValueKey(item.id), // Add key for better performance
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
        leading: _buildItemIcon(item.normalizedType),
        title: Text(
          item.displayName,
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
          if (item.obtainedFrom.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDropLocations(item),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactItemCard(Weapon item, int index) {
    final mainStat = _getMainStat(item);

    return Card(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: const Color(0xFF10A37F).withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Expand to detailed view when tapped
          setState(() {
            _compactView = false;
          });
          // Could also implement a dialog/modal here
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF10A37F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getIconForType(item.normalizedType),
                  color: const Color(0xFF10A37F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Name and type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTypeDisplayName(item.type),
                      style: const TextStyle(
                        color: Color(0xFF10A37F),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Main stat
              if (mainStat != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF313440),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mainStat['label']!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mainStat['value']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Expand arrow
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Colors.white38,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String>? _getMainStat(Weapon item) {
    // Return the most relevant stat based on weapon type
    if (item.baseAtk > 0) {
      return {'label': 'ATK', 'value': item.baseAtk.toString()};
    }
    if (item.baseMatk > 0) {
      return {'label': 'MATK', 'value': item.baseMatk.toString()};
    }
    if (item.baseDef > 0) {
      return {'label': 'DEF', 'value': item.baseDef.toString()};
    }
    if (item.baseStability > 0) {
      return {
        'label': 'Stability',
        'value': '${item.baseStability.toStringAsFixed(0)}%'
      };
    }
    return null;
  }

  IconData _getIconForType(String normalizedType) {
    switch (normalizedType) {
      case 'one_handed_sword':
      case 'two_handed_sword':
      case 'dagger':
      case 'katana':
        return Icons.gavel;
      case 'bow':
      case 'bowgun':
        return Icons.gps_fixed;
      case 'staff':
      case 'magic_device':
        return Icons.auto_fix_high;
      case 'knuckle':
      case 'halberd':
        return Icons.sports_martial_arts;
      case 'shield':
        return Icons.shield;
      case 'arrow':
        return Icons.arrow_forward;
      case 'armor':
      case 'additional':
        return Icons.shield_outlined;
      case 'special':
        return Icons.stars;
      default:
        return Icons.category;
    }
  }

  Widget _buildItemIcon(String normalizedType) {
    IconData iconData;
    Color iconColor;

    switch (normalizedType) {
      case 'one_handed_sword':
      case 'two_handed_sword':
      case 'dagger':
      case 'katana':
        iconData = Icons.gavel;
        iconColor = const Color(0xFFFF6B6B);
        break;
      case 'bow':
      case 'bowgun':
        iconData = Icons.sports_cricket;
        iconColor = const Color(0xFFFF9F43);
        break;
      case 'staff':
      case 'magic_device':
        iconData = Icons.auto_fix_high;
        iconColor = const Color(0xFF9B59B6);
        break;
      case 'knuckles':
        iconData = Icons.sports_mma;
        iconColor = const Color(0xFFE74C3C);
        break;
      case 'halberd':
        iconData = Icons.carpenter;
        iconColor = const Color(0xFF3498DB);
        break;
      case 'shield':
        iconData = Icons.shield;
        iconColor = const Color(0xFF4ECDC4);
        break;
      case 'arrow':
        iconData = Icons.arrow_forward;
        iconColor = const Color(0xFFFECA57);
        break;
      case 'armor':
        iconData = Icons.shield_outlined;
        iconColor = const Color(0xFF95E1D3);
        break;
      case 'additional':
        iconData = Icons.sports_motorsports;
        iconColor = const Color(0xFFFECA57);
        break;
      case 'special':
        iconData = Icons.circle_outlined;
        iconColor = const Color(0xFFEE5A6F);
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = Colors.grey;
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

  Widget _buildStatsTable(Weapon item) {
    if (item.stats.isEmpty) {
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
        children: item.stats.map((stat) {
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
                  stat.name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                Text(
                  stat.amount,
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

  Widget _buildDropLocations(Weapon item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF10A37F),
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'Obtained From:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...item.obtainedFrom.take(5).map((drop) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drop.monster,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  if (drop.map.isNotEmpty)
                    Text(
                      '  📍 ${drop.map}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          if (item.obtainedFrom.length > 5)
            Text(
              '  ... and ${item.obtainedFrom.length - 5} more locations',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
