import '../models/character_stats.dart';
import '../models/weapon.dart';
import '../models/crystal.dart';

class CalcService {
  static int calcATK(CharacterStats stats, Weapon? w) {
    if (w == null) return (stats.str * 2);
    final str = stats.enabled ? stats.str : 0;
    final refineBonus = w.refine * 2;
    return (str * 2) + w.watk + refineBonus;
  }

  static int calcMATK(CharacterStats stats) {
    if (!stats.enabled) return 0;
    return stats.intStat * 2;
  }

  static int calcHP(CharacterStats stats) {
    if (!stats.enabled) return 0;
    return 1000 + stats.vit * 10;
  }

  static int calcCritRate(CharacterStats stats) {
    if (!stats.enabled) return 0;
    return 25 + (stats.dex ~/ 2);
  }

  static Map<String, num> mergeCrystalStats(List<Crystal> crystals) {
    final Map<String, num> total = {};
    for (final c in crystals) {
      c.stats.forEach((k, v) {
        total[k] = (total[k] ?? 0) + v;
      });
    }
    return total;
  }

  static Map<String, dynamic> calculateBuild({
    required CharacterStats stats,
    Weapon? weapon,
    required List<Crystal> crystals,
  }) {
    final atk = calcATK(stats, weapon);
    final matk = calcMATK(stats);
    final hp = calcHP(stats);
    final crit = calcCritRate(stats);
    final crystalTotals = mergeCrystalStats(crystals);

    return {
      'ATK': atk + (crystalTotals['ATK']?.toInt() ?? 0),
      'MATK': matk + (crystalTotals['MATK']?.toInt() ?? 0),
      'HP': hp + (crystalTotals['HP']?.toInt() ?? 0),
      'CritRate': crit + (crystalTotals['CRIT%']?.toInt() ?? 0),
      'Crystals': crystalTotals,
    };
  }
}
