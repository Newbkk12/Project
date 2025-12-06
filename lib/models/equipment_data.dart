
import 'dart:convert';

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

// Equipment lists (ported from HTML / JS)
class EquipmentData {
  static final List<EquipmentItem> items = <EquipmentItem>[
    // Main weapon
    EquipmentItem(
      id: 'legendary_katana',
      name: 'Legendary Katana',
      type: EquipmentType.mainWeapon,
      atk: 200,
      str: 15,
      dex: 8,
      aspd: 500,
    ),
    EquipmentItem(
      id: 'master_bow',
      name: 'Master Bow',
      type: EquipmentType.mainWeapon,
      atk: 180,
      dex: 20,
      agi: 10,
      aspd: 300,
    ),
    EquipmentItem(
      id: 'arcane_staff',
      name: 'Arcane Staff',
      type: EquipmentType.mainWeapon,
      matk: 220,
      intStat: 25,
      mdef: 15,
      mp: 400,
    ),
    EquipmentItem(
      id: 'fury_knuckles',
      name: 'Fury Knuckles',
      type: EquipmentType.mainWeapon,
      atk: 160,
      str: 12,
      agi: 15,
      aspd: 600,
    ),

    // Sub weapon
    EquipmentItem(
      id: 'guardian_shield',
      name: 'Guardian Shield',
      type: EquipmentType.subWeapon,
      def: 60,
      vit: 12,
      hp: 400,
    ),
    EquipmentItem(
      id: 'shadow_dagger',
      name: 'Shadow Dagger',
      type: EquipmentType.subWeapon,
      atk: 80,
      agi: 15,
      aspd: 200,
      critRate: 8,
    ),
    EquipmentItem(
      id: 'magic_quiver',
      name: 'Magic Quiver',
      type: EquipmentType.subWeapon,
      dex: 18,
      accuracy: 15,
      aspd: 150,
      mp: 200,
    ),
    EquipmentItem(
      id: 'wisdom_tome',
      name: 'Wisdom Tome',
      type: EquipmentType.subWeapon,
      matk: 100,
      intStat: 20,
      mp: 500,
      mdef: 25,
    ),

    // Armor
    EquipmentItem(
      id: 'dragon_plate',
      name: 'Dragon Plate',
      type: EquipmentType.armor,
      def: 120,
      vit: 20,
      str: 8,
      hp: 800,
    ),
    EquipmentItem(
      id: 'archmage_robe',
      name: 'Archmage Robe',
      type: EquipmentType.armor,
      mdef: 100,
      intStat: 18,
      mp: 600,
    ),
    EquipmentItem(
      id: 'assassin_leather',
      name: 'Assassin Leather',
      type: EquipmentType.armor,
      def: 80,
      agi: 25,
      dex: 12,
      aspd: 200,
    ),
    EquipmentItem(
      id: 'knight_mail',
      name: 'Knight Mail',
      type: EquipmentType.armor,
      def: 140,
      vit: 25,
      str: 10,
      hp: 1000,
    ),

    // Helmet
    EquipmentItem(
      id: 'crown_wisdom',
      name: 'Crown of Wisdom',
      type: EquipmentType.helmet,
      mdef: 30,
      intStat: 20,
      mp: 300,
    ),
    EquipmentItem(
      id: 'warrior_helm',
      name: 'Warrior Helm',
      type: EquipmentType.helmet,
      def: 40,
      str: 15,
      atk: 20,
    ),
    EquipmentItem(
      id: 'ranger_cap',
      name: 'Ranger Cap',
      type: EquipmentType.helmet,
      def: 25,
      dex: 18,
      agi: 12,
      aspd: 150,
    ),
    EquipmentItem(
      id: 'mage_circlet',
      name: 'Mage Circlet',
      type: EquipmentType.helmet,
      mdef: 35,
      intStat: 22,
      matk: 30,
    ),

    // Ring
    EquipmentItem(
      id: 'power_ring',
      name: 'Ring of Power',
      type: EquipmentType.ring,
      atk: 25,
      str: 10,
      critRate: 5,
    ),
    EquipmentItem(
      id: 'magic_ring',
      name: 'Ring of Magic',
      type: EquipmentType.ring,
      matk: 30,
      intStat: 12,
      mp: 200,
    ),
    EquipmentItem(
      id: 'protection_ring',
      name: 'Ring of Protection',
      type: EquipmentType.ring,
      def: 30,
      mdef: 25,
      vit: 8,
      hp: 300,
    ),
    EquipmentItem(
      id: 'speed_ring',
      name: 'Ring of Speed',
      type: EquipmentType.ring,
      aspd: 400,
      agi: 15,
      dex: 10,
    ),
  ];

  static final List<CrystalBonus> crystalBonuses = <CrystalBonus>[
    CrystalBonus(id: 'atk_boost', stats: {'atk': 20, 'str': 5}),
    CrystalBonus(id: 'crit_rate', stats: {'crit_rate': 8, 'dex': 6}),
    CrystalBonus(id: 'accuracy', stats: {'accuracy': 10, 'dex': 4}),
    CrystalBonus(id: 'piercing', stats: {'physical_pierce': 5, 'atk': 10}),
    CrystalBonus(id: 'aspd', stats: {'aspd': 200, 'agi': 8}),
    CrystalBonus(id: 'stability', stats: {'stability': 8, 'atk': 5}),
    CrystalBonus(id: 'def_boost', stats: {'def': 25, 'vit': 6}),
    CrystalBonus(id: 'hp_boost', stats: {'hp': 400, 'vit': 8}),
    CrystalBonus(id: 'vit_boost', stats: {'vit': 10, 'hp': 200}),
    CrystalBonus(id: 'mdef_boost', stats: {'mdef': 20, 'intStat': 5}),
    CrystalBonus(id: 'dodge', stats: {'agi': 8}),
    CrystalBonus(id: 'guard_rate', stats: {'def': 10}),
    CrystalBonus(id: 'str_boost', stats: {'str': 8, 'atk': 15}),
    CrystalBonus(id: 'int_boost', stats: {'intStat': 8, 'matk': 20}),
    CrystalBonus(id: 'dex_boost', stats: {'dex': 8, 'accuracy': 5}),
    CrystalBonus(id: 'agi_boost', stats: {'agi': 8, 'aspd': 150}),
    CrystalBonus(id: 'all_stats', stats: {'str': 5, 'dex': 5, 'intStat': 5, 'agi': 5, 'vit': 5}),
    CrystalBonus(id: 'crit_special', stats: {'crit_rate': 12}),
    CrystalBonus(id: 'exp_boost', stats: {}),
  ];

  static final List<GachaStatBonus> gachaBonuses = <GachaStatBonus>[
    GachaStatBonus(
      id: 'atk_percent',
      type: 'percent',
      stat: 'atk',
      value: 10,
      display: 'ATK +10%',
    ),
    GachaStatBonus(
      id: 'matk_percent',
      type: 'percent',
      stat: 'matk',
      value: 8,
      display: 'MATK +8%',
    ),
    GachaStatBonus(
      id: 'crit_rate_boost',
      type: 'flat',
      stat: 'crit_rate',
      value: 15,
      display: 'Critical Rate +15%',
    ),
    GachaStatBonus(
      id: 'hp_flat',
      type: 'flat',
      stat: 'hp',
      value: 500,
      display: 'HP +500',
    ),
    GachaStatBonus(
      id: 'mp_flat',
      type: 'flat',
      stat: 'mp',
      value: 300,
      display: 'MP +300',
    ),
    GachaStatBonus(
      id: 'def_flat',
      type: 'flat',
      stat: 'def',
      value: 50,
      display: 'DEF +50',
    ),
    GachaStatBonus(
      id: 'stability_boost',
      type: 'flat',
      stat: 'stability',
      value: 5,
      display: 'Stability +5%',
    ),
    GachaStatBonus(
      id: 'aspd_flat',
      type: 'flat',
      stat: 'aspd',
      value: 200,
      display: 'ASPD +200',
    ),
    GachaStatBonus(
      id: 'str_flat',
      type: 'flat',
      stat: 'str',
      value: 12,
      display: 'STR +12',
    ),
    GachaStatBonus(
      id: 'dex_flat',
      type: 'flat',
      stat: 'dex',
      value: 12,
      display: 'DEX +12',
    ),
    GachaStatBonus(
      id: 'int_flat',
      type: 'flat',
      stat: 'intStat',
      value: 12,
      display: 'INT +12',
    ),
    GachaStatBonus(
      id: 'agi_flat',
      type: 'flat',
      stat: 'agi',
      value: 12,
      display: 'AGI +12',
    ),
    GachaStatBonus(
      id: 'vit_flat',
      type: 'flat',
      stat: 'vit',
      value: 12,
      display: 'VIT +12',
    ),
    GachaStatBonus(
      id: 'accuracy_boost',
      type: 'flat',
      stat: 'accuracy',
      value: 8,
      display: 'Accuracy +8%',
    ),
    GachaStatBonus(
      id: 'pierce_flat',
      type: 'flat',
      stat: 'physical_pierce',
      value: 8,
      display: 'Physical Pierce +8',
    ),
    GachaStatBonus(
      id: 'mdef_flat',
      type: 'flat',
      stat: 'mdef',
      value: 40,
      display: 'MDEF +40',
    ),
    GachaStatBonus(
      id: 'element_pierce',
      type: 'flat',
      stat: 'element_pierce',
      value: 6,
      display: 'Element Pierce +6',
    ),
    GachaStatBonus(
      id: 'crit_dmg',
      type: 'flat',
      stat: 'crit_rate',
      value: 0,
      display: 'Critical Damage +20%',
    ),
    GachaStatBonus(
      id: 'magic_pierce',
      type: 'flat',
      stat: 'matk',
      value: 0,
      display: 'Magic Pierce +5',
    ),
    GachaStatBonus(
      id: 'natural_hp',
      type: 'flat',
      stat: 'hp',
      value: 0,
      display: 'Natural HP Regen +15',
    ),
    GachaStatBonus(
      id: 'natural_mp',
      type: 'flat',
      stat: 'mp',
      value: 0,
      display: 'Natural MP Regen +10',
    ),
    GachaStatBonus(
      id: 'exp_rate',
      type: 'flat',
      stat: 'atk',
      value: 0,
      display: 'EXP Rate +25%',
    ),
  ];

  static CrystalBonus? findCrystal(String id) {
    for (int i = 0; i < crystalBonuses.length; i++) {
      if (crystalBonuses[i].id == id) return crystalBonuses[i];
    }
    return null;
  }

  static GachaStatBonus? findGacha(String id) {
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

  static List<EquipmentItem> itemsByType(EquipmentType type) {
    final result = <EquipmentItem>[];
    for (int i = 0; i < items.length; i++) {
      if (items[i].type == type) {
        result.add(items[i]);
      }
    }
    return result;
  }

  static String encodeBuild(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  static Map<String, dynamic> decodeBuild(String raw) {
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
