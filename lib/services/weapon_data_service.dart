import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/equipment_data.dart';

// -----------------------------------------------------------------------------
// WeaponDataService
// - Loads and caches weapon data from JSON files
// - Provides search and filter functionality
// -----------------------------------------------------------------------------

class WeaponDataService {
  static final WeaponDataService _instance = WeaponDataService._internal();
  factory WeaponDataService() => _instance;
  WeaponDataService._internal();

  // Cache for loaded weapons
  final Map<String, List<Weapon>> _cache = {};
  bool _isInitialized = false;

  // File mappings
  static const Map<String, String> _fileMap = {
    'one_handed_sword': 'lib/data/wepon/wepondata/coryn_1h_sword_cards.json',
    'two_handed_sword': 'lib/data/wepon/wepondata/coryn_2h_sword_cards.json',
    'bow': 'lib/data/wepon/wepondata/coryn_bow_cards.json',
    'bowgun': 'lib/data/wepon/wepondata/coryn_bowgun_cards.json',
    'dagger': 'lib/data/wepon/wepondata/coryn_dagger_cards.json',
    'halberd': 'lib/data/wepon/wepondata/coryn_halberd_cards.json',
    'katana': 'lib/data/wepon/wepondata/coryn_katana_cards.json',
    'knuckles': 'lib/data/wepon/wepondata/coryn_knuckles_cards.json',
    'magic_device': 'lib/data/wepon/wepondata/coryn_magic_device_cards.json',
    'ninjutsu_scroll':
        'lib/data/wepon/wepondata/coryn_ninjutsu_scroll_cards.json',
    'shield': 'lib/data/wepon/wepondata/coryn_shield_cards.json',
    'staff': 'lib/data/wepon/wepondata/coryn_staff_cards.json',
    'arrow': 'lib/data/wepon/wepondata/coryn_arrow_cards.json',
    'armor': 'lib/data/wepon/wepondata/coryn_armor_cards.json',
    'additional': 'lib/data/wepon/wepondata/coryn_additional_cards.json',
    'special': 'lib/data/wepon/wepondata/coryn_special_cards.json',
  };

  // Initialize service by loading all weapon data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      for (final entry in _fileMap.entries) {
        final type = entry.key;
        final path = entry.value;

        try {
          final jsonString = await rootBundle.loadString(path);
          final List<dynamic> jsonList = json.decode(jsonString);
          final weapons = jsonList.map((j) => Weapon.fromJson(j)).toList();
          _cache[type] = weapons;
        } catch (e) {
          print('Error loading $type weapons: $e');
          _cache[type] = [];
        }
      }

      _isInitialized = true;
      print('WeaponDataService initialized with ${getTotalCount()} weapons');
    } catch (e) {
      print('Error initializing WeaponDataService: $e');
      _isInitialized = false;
    }
  }

  // Get all weapons of a specific type
  List<Weapon> getWeaponsByType(String type) {
    return _cache[type] ?? [];
  }

  // Get all weapons
  List<Weapon> getAllWeapons() {
    final all = <Weapon>[];
    for (final weapons in _cache.values) {
      all.addAll(weapons);
    }
    return all;
  }

  // Get total weapon count
  int getTotalCount() {
    return getAllWeapons().length;
  }

  // Find weapon by ID (searches all types)
  Weapon? findById(int id) {
    for (final weapons in _cache.values) {
      try {
        return weapons.firstWhere((w) => w.id == id);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // Find weapon by title (exact match)
  Weapon? findByTitle(String title) {
    for (final weapons in _cache.values) {
      try {
        return weapons.firstWhere((w) => w.title == title);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // Search weapons by name (partial match, case-insensitive)
  List<Weapon> search({
    String? query,
    String? type,
    String? category,
    bool onlyWithStats = false,
  }) {
    List<Weapon> results = getAllWeapons();

    // Filter by type
    if (type != null && type.isNotEmpty) {
      results = results.where((w) => w.normalizedType == type).toList();
    }

    // Filter by category
    if (category != null && category.isNotEmpty && category != 'All') {
      results = results.where((w) => w.category == category).toList();
    }

    // Filter by query
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((w) {
        return w.title.toLowerCase().contains(lowerQuery) ||
            w.displayName.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Filter only weapons with stats
    if (onlyWithStats) {
      results = results.where((w) => w.hasStats).toList();
    }

    return results;
  }

  // Get weapons by category (for database screen)
  List<Weapon> getWeaponsByCategory(String category) {
    if (category == 'All') {
      return getAllWeapons();
    }
    return getAllWeapons().where((w) => w.category == category).toList();
  }

  // Get main weapon types (for build simulator)
  List<Weapon> getMainWeapons() {
    final types = [
      'one_handed_sword',
      'two_handed_sword',
      'bow',
      'bowgun',
      'dagger',
      'halberd',
      'katana',
      'knuckles',
      'magic_device',
      'staff',
    ];

    final weapons = <Weapon>[];
    for (final type in types) {
      weapons.addAll(getWeaponsByType(type));
    }
    return weapons.where((w) => w.hasStats).toList();
  }

  // Get sub weapons (shields, arrows)
  List<Weapon> getSubWeapons() {
    final shields = getWeaponsByType('shield');
    final arrows = getWeaponsByType('arrow');
    final all = [...shields, ...arrows];
    return all.where((w) => w.hasStats).toList();
  }

  // Get armor
  List<Weapon> getArmor() {
    return getWeaponsByType('armor').where((w) => w.hasStats).toList();
  }

  // Get additional gear (helmets, etc.)
  List<Weapon> getAdditionalGear() {
    return getWeaponsByType('additional').where((w) => w.hasStats).toList();
  }

  // Get special gear (rings, etc.)
  List<Weapon> getSpecialGear() {
    return getWeaponsByType('special').where((w) => w.hasStats).toList();
  }

  // Get weapons sorted by base ATK
  List<Weapon> getTopAttackWeapons({int limit = 10}) {
    final weapons = getMainWeapons();
    weapons.sort((a, b) => b.baseAtk.compareTo(a.baseAtk));
    return weapons.take(limit).toList();
  }

  // Get weapons sorted by base MATK
  List<Weapon> getTopMagicWeapons({int limit = 10}) {
    final weapons = getMainWeapons();
    weapons.sort((a, b) => b.baseMatk.compareTo(a.baseMatk));
    return weapons.take(limit).toList();
  }

  // Check if service is initialized
  bool get isInitialized => _isInitialized;

  // Clear cache (for testing/debugging)
  void clearCache() {
    _cache.clear();
    _isInitialized = false;
  }
}
