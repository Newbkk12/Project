import 'dart:convert';
import '../services/weapon_data_service.dart';

// -----------------------------------------------------------------------------
// Weapon Model Classes
// - Represents weapon/equipment data from Coryn Club JSON files
// - Handles parsing and stat extraction
// -----------------------------------------------------------------------------

class WeaponStat {
  final String name;
  final String amount;

  WeaponStat({
    required this.name,
    required this.amount,
  });

  factory WeaponStat.fromJson(Map<String, dynamic> json) {
    return WeaponStat(
      name: json['name'] ?? '',
      amount: json['amount']?.toString() ?? '0',
    );
  }

  // Parse amount as integer (handles both string and int)
  int get intValue {
    try {
      return int.parse(amount.replaceAll(RegExp(r'[^0-9-]'), ''));
    } catch (_) {
      return 0;
    }
  }

  // Parse amount as double (for percentage values)
  double get doubleValue {
    try {
      return double.parse(amount.replaceAll(RegExp(r'[^0-9.-]'), ''));
    } catch (_) {
      return 0.0;
    }
  }
}

class DropLocation {
  final String monster;
  final String dye;
  final String map;

  DropLocation({
    required this.monster,
    required this.dye,
    required this.map,
  });

  factory DropLocation.fromJson(Map<String, dynamic> json) {
    return DropLocation(
      monster: json['monster'] ?? '',
      dye: json['dye'] ?? '',
      map: json['map'] ?? '',
    );
  }
}

class Weapon {
  final int id;
  final String title;
  final String type;
  final Map<String, String> props;
  final List<String> statHeader;
  final List<WeaponStat> stats;
  final List<DropLocation> obtainedFrom;

  Weapon({
    required this.id,
    required this.title,
    required this.type,
    required this.props,
    required this.statHeader,
    required this.stats,
    required this.obtainedFrom,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      props: Map<String, String>.from(json['props'] ?? {}),
      statHeader: List<String>.from(json['stat_header'] ?? []),
      stats: (json['stats'] as List<dynamic>?)
              ?.map((s) => WeaponStat.fromJson(s))
              .toList() ??
          [],
      obtainedFrom: (json['obtained_from'] as List<dynamic>?)
              ?.map((o) => DropLocation.fromJson(o))
              .toList() ??
          [],
    );
  }

  // Helper methods to get specific stats
  int get baseAtk => _getStatInt('Base ATK');
  int get baseMatk => _getStatInt('Base MATK');
  int get baseDef => _getStatInt('DEF');
  double get baseStability => _getStatDouble('Base Stability %');
  int get attackRange => _getStatInt('Attack Range');
  int get aggro => _getStatInt('Aggro %');
  int get attackMpRecovery => _getStatInt('Attack MP Recovery');
  int get str => _getStatInt('STR');
  int get intStat => _getStatInt('INT');
  int get vit => _getStatInt('VIT');
  int get agi => _getStatInt('AGI');
  int get dex => _getStatInt('DEX');
  double get criticalRate => _getStatDouble('Critical Rate %');
  double get accuracy => _getStatDouble('Accuracy %');
  int get dodge => _getStatInt('Dodge %');
  int get physicalResistance => _getStatInt('Physical Resistance %');
  int get magicalResistance => _getStatInt('Magical Resistance %');
  int get maxHp => _getStatInt('MaxHP');
  int get maxMp => _getStatInt('MaxMP');
  int get hpRegen => _getStatInt('HP Regen');
  int get mpRegen => _getStatInt('MP Regen');
  double get physicalPierce => _getStatDouble('Physical Pierce %');
  double get magicalPierce => _getStatDouble('Magical Pierce %');
  int get aspd => _getStatInt('ASPD');
  int get cspd => _getStatInt('CSPD');

  int _getStatInt(String statName) {
    final stat = stats.firstWhere(
      (s) => s.name == statName,
      orElse: () => WeaponStat(name: '', amount: '0'),
    );
    return stat.intValue;
  }

  double _getStatDouble(String statName) {
    final stat = stats.firstWhere(
      (s) => s.name == statName,
      orElse: () => WeaponStat(name: '', amount: '0'),
    );
    return stat.doubleValue;
  }

  // Get normalized weapon type (for filtering)
  String get normalizedType {
    final lower = type.toLowerCase();
    if (lower.contains('sword') && lower.contains('1'))
      return 'one_handed_sword';
    if (lower.contains('sword') && lower.contains('2'))
      return 'two_handed_sword';
    if (lower.contains('bow') && !lower.contains('gun')) return 'bow';
    if (lower.contains('bowgun')) return 'bowgun';
    if (lower.contains('dagger')) return 'dagger';
    if (lower.contains('halberd')) return 'halberd';
    if (lower.contains('katana')) return 'katana';
    if (lower.contains('knuckle')) return 'knuckles';
    if (lower.contains('magic')) return 'magic_device';
    if (lower.contains('ninjutsu')) return 'ninjutsu_scroll';
    if (lower.contains('shield')) return 'shield';
    if (lower.contains('staff')) return 'staff';
    if (lower.contains('arrow')) return 'arrow';
    if (lower.contains('armor')) return 'armor';
    if (lower.contains('additional')) return 'additional';
    if (lower.contains('special')) return 'special';
    return 'unknown';
  }

  // Get weapon category for database screen
  String get category {
    final norm = normalizedType;
    if (norm == 'armor') return 'Body Armor';
    if (norm == 'additional') return 'Additional Gear';
    if (norm == 'special') return 'Special Gear';
    if (norm == 'shield' || norm == 'arrow') return 'Sub Weapon';
    return 'Weapon';
  }

  // Get clean display name (remove type suffix)
  String get displayName {
    final pattern = RegExp(r'\s*\[.*?\]\s*$');
    return title.replaceAll(pattern, '').trim();
  }

  // Check if weapon has any stats
  bool get hasStats => stats.isNotEmpty;

  // Get sell price as integer
  int get sellPrice {
    final sellStr = props['Sell'] ?? '0';
    try {
      return int.parse(sellStr.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (_) {
      return 0;
    }
  }

  // Get process amount as integer
  int get processAmount {
    final processStr = props['Process'] ?? '0';
    try {
      return int.parse(processStr.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (_) {
      return 0;
    }
  }
}

// -----------------------------------------------------------------------------
// Equipment Types and Items
// -----------------------------------------------------------------------------

enum EquipmentType {
  mainWeapon,
  subWeapon,
  armor,
  helmet,
  ring,
}

class EquipmentItem {
  final String id;
  final String name;
  final EquipmentType type;
  final String?
      weaponType; // Original weapon type from JSON (e.g., "1H Sword", "Bow")

  final int atk;
  final int matk;
  final int def;
  final int mdef;
  final int str;
  final int dex;
  final int intStat;
  final int agi;
  final int vit;
  final int aspd;
  final int critRate;
  final int accuracy;
  final int stability;
  final int physicalPierce;
  final int elementPierce;
  final int hp;
  final int mp;

  const EquipmentItem({
    required this.id,
    required this.name,
    required this.type,
    this.weaponType,
    this.atk = 0,
    this.matk = 0,
    this.def = 0,
    this.mdef = 0,
    this.str = 0,
    this.dex = 0,
    this.intStat = 0,
    this.agi = 0,
    this.vit = 0,
    this.aspd = 0,
    this.critRate = 0,
    this.accuracy = 0,
    this.stability = 0,
    this.physicalPierce = 0,
    this.elementPierce = 0,
    this.hp = 0,
    this.mp = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'atk': atk,
      'matk': matk,
      'def': def,
      'mdef': mdef,
      'str': str,
      'dex': dex,
      'intStat': intStat,
      'agi': agi,
      'vit': vit,
      'aspd': aspd,
      'critRate': critRate,
      'accuracy': accuracy,
      'stability': stability,
      'physicalPierce': physicalPierce,
      'elementPierce': elementPierce,
      'hp': hp,
      'mp': mp,
    };
  }

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: EquipmentType.values[json['type'] ?? 0],
      atk: json['atk'] ?? 0,
      matk: json['matk'] ?? 0,
      def: json['def'] ?? 0,
      mdef: json['mdef'] ?? 0,
      str: json['str'] ?? 0,
      dex: json['dex'] ?? 0,
      intStat: json['intStat'] ?? 0,
      agi: json['agi'] ?? 0,
      vit: json['vit'] ?? 0,
      aspd: json['aspd'] ?? 0,
      critRate: json['critRate'] ?? 0,
      accuracy: json['accuracy'] ?? 0,
      stability: json['stability'] ?? 0,
      physicalPierce: json['physicalPierce'] ?? 0,
      elementPierce: json['elementPierce'] ?? 0,
      hp: json['hp'] ?? 0,
      mp: json['mp'] ?? 0,
    );
  }
}

class CrystalBonus {
  final String id;
  final Map<String, int> stats;

  CrystalBonus({
    required this.id,
    required this.stats,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stats': stats,
    };
  }

  factory CrystalBonus.fromJson(Map<String, dynamic> json) {
    final raw = json['stats'] as Map<String, dynamic>? ?? {};
    final converted = <String, int>{};
    raw.forEach((key, value) {
      converted[key] = value is int ? value : int.tryParse('$value') ?? 0;
    });
    return CrystalBonus(
      id: json['id'] ?? '',
      stats: converted,
    );
  }
}

class GachaStatBonus {
  final String id;
  final String type; // 'flat' or 'percent'
  final String stat;
  final int value;
  final String display;

  GachaStatBonus({
    required this.id,
    required this.type,
    required this.stat,
    required this.value,
    required this.display,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'stat': stat,
      'value': value,
      'display': display,
    };
  }

  factory GachaStatBonus.fromJson(Map<String, dynamic> json) {
    return GachaStatBonus(
      id: json['id'] ?? '',
      type: json['type'] ?? 'flat',
      stat: json['stat'] ?? '',
      value: json['value'] ?? 0,
      display: json['display'] ?? '',
    );
  }
}

// Equipment lists and data management
class EquipmentData {
  static final List<EquipmentItem> items = <EquipmentItem>[];

  static final List<CrystalBonus> crystalBonuses = <CrystalBonus>[
    CrystalBonus(id: 'DEF +10', stats: {'def': 10}),
    CrystalBonus(id: 'ATK +5', stats: {'atk': 5}),
    CrystalBonus(id: 'MATK +5', stats: {'matk': 5}),
    CrystalBonus(id: 'HP +100', stats: {'hp': 100}),
    CrystalBonus(id: 'MP +50', stats: {'mp': 50}),
    CrystalBonus(id: 'STR +3', stats: {'str': 3}),
    CrystalBonus(id: 'DEX +3', stats: {'dex': 3}),
    CrystalBonus(id: 'INT +3', stats: {'intStat': 3}),
    CrystalBonus(id: 'AGI +3', stats: {'agi': 3}),
    CrystalBonus(id: 'VIT +3', stats: {'vit': 3}),
  ];

  static final List<GachaStatBonus> gachaBonuses = <GachaStatBonus>[
    GachaStatBonus(
        id: 'atk_3',
        type: 'percent',
        stat: 'atk',
        value: 3,
        display: 'ATK +3%'),
    GachaStatBonus(
        id: 'atk_5',
        type: 'percent',
        stat: 'atk',
        value: 5,
        display: 'ATK +5%'),
    GachaStatBonus(
        id: 'matk_3',
        type: 'percent',
        stat: 'matk',
        value: 3,
        display: 'MATK +3%'),
    GachaStatBonus(
        id: 'matk_5',
        type: 'percent',
        stat: 'matk',
        value: 5,
        display: 'MATK +5%'),
    GachaStatBonus(
        id: 'def_3',
        type: 'percent',
        stat: 'def',
        value: 3,
        display: 'DEF +3%'),
    GachaStatBonus(
        id: 'aspd_100',
        type: 'flat',
        stat: 'aspd',
        value: 100,
        display: 'ASPD +100'),
    GachaStatBonus(
        id: 'crit_rate_5',
        type: 'flat',
        stat: 'crit_rate',
        value: 5,
        display: 'Critical Rate +5%'),
    GachaStatBonus(
        id: 'physical_pierce_3',
        type: 'flat',
        stat: 'physical_pierce',
        value: 3,
        display: 'Physical Pierce +3%'),
    GachaStatBonus(
        id: 'str_5', type: 'flat', stat: 'str', value: 5, display: 'STR +5'),
    GachaStatBonus(
        id: 'dex_5', type: 'flat', stat: 'dex', value: 5, display: 'DEX +5'),
    GachaStatBonus(
        id: 'int_5',
        type: 'flat',
        stat: 'intStat',
        value: 5,
        display: 'INT +5'),
    GachaStatBonus(
        id: 'agi_5', type: 'flat', stat: 'agi', value: 5, display: 'AGI +5'),
    GachaStatBonus(
        id: 'vit_5', type: 'flat', stat: 'vit', value: 5, display: 'VIT +5'),
  ];

  static CrystalBonus? findCrystal(String? id) {
    if (id == null || id.isEmpty) return null;
    for (int i = 0; i < crystalBonuses.length; i++) {
      if (crystalBonuses[i].id == id) return crystalBonuses[i];
    }
    return null;
  }

  static GachaStatBonus? findGacha(String? id) {
    if (id == null || id.isEmpty) return null;
    for (int i = 0; i < gachaBonuses.length; i++) {
      if (gachaBonuses[i].id == id) return gachaBonuses[i];
    }
    return null;
  }

  static EquipmentItem? findItem(String? id) {
    if (id == null || id.isEmpty) return null;
    for (int i = 0; i < items.length; i++) {
      if (items[i].id == id) return items[i];
    }
    return null;
  }

  // Cache for itemsByType to avoid repeated filtering
  static final Map<EquipmentType, List<EquipmentItem>> _itemsByTypeCache = {};

  static List<EquipmentItem> itemsByType(EquipmentType type) {
    // Return cached list if available
    if (_itemsByTypeCache.containsKey(type)) {
      return _itemsByTypeCache[type]!;
    }

    // Build and cache the filtered list
    final result = <EquipmentItem>[];
    for (int i = 0; i < items.length; i++) {
      if (items[i].type == type) {
        result.add(items[i]);
      }
    }
    _itemsByTypeCache[type] = result;
    return result;
  }

  // Clear cache when items list changes
  static void clearCache() {
    _itemsByTypeCache.clear();
  }

  static String encodeBuild(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  static Map<String, dynamic> decodeBuild(String raw) {
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // Convert Weapon to EquipmentItem
  static EquipmentItem weaponToEquipmentItem(Weapon weapon) {
    EquipmentType type;
    switch (weapon.category) {
      case 'Weapon':
        type = EquipmentType.mainWeapon;
        break;
      case 'Sub Weapon':
        type = EquipmentType.subWeapon;
        break;
      case 'Body Armor':
        type = EquipmentType.armor;
        break;
      case 'Additional Gear':
        type = EquipmentType.helmet;
        break;
      case 'Special Gear':
        type = EquipmentType.ring;
        break;
      default:
        type = EquipmentType.mainWeapon;
    }

    return EquipmentItem(
      id: 'weapon_${weapon.id}',
      name: weapon.displayName,
      type: type,
      weaponType: weapon.type,
      atk: weapon.baseAtk,
      matk: weapon.baseMatk,
      def: weapon.baseDef,
      str: weapon.str,
      dex: weapon.dex,
      intStat: weapon.intStat,
      agi: weapon.agi,
      vit: weapon.vit,
      aspd: weapon.aspd,
      critRate: weapon.criticalRate.toInt(),
      accuracy: weapon.accuracy.toInt(),
      stability: weapon.baseStability.toInt(),
      physicalPierce: weapon.physicalPierce.toInt(),
      hp: weapon.maxHp,
      mp: weapon.maxMp,
    );
  }

  // Populate items from WeaponDataService
  static void loadFromWeaponService(WeaponDataService service) {
    final allWeapons = service.search(onlyWithStats: true);
    final convertedItems =
        allWeapons.map((w) => weaponToEquipmentItem(w)).toList();
    items.clear();
    items.addAll(convertedItems);

    // Clear cache when items are reloaded
    clearCache();
  }
}
