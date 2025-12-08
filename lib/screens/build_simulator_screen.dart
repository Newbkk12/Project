// Core libs
import 'dart:convert';
import '../services/local_storage.dart';

// Flutter
import 'package:flutter/material.dart';

// Local models & data
import '../models/character_stats.dart';
import '../models/equipment_data.dart';
import '../providers/theme_provider.dart';

// Widgets
import '../widgets/common/toram_card.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';
import '../widgets/navigation/navigation_rail.dart';
import '../widgets/build_page/character_stats_card.dart';
import '../widgets/build_page/gacha_card.dart';
import '../widgets/build_page/main_weapon_selector.dart';
import '../widgets/build_page/sub_weapon_selector.dart';
import '../widgets/build_page/armor_selector.dart';
import '../widgets/build_page/helmet_selector.dart';
import '../widgets/build_page/ring_selector.dart';

// -----------------------------------------------------------------------------
// Build Simulator Screen
// - Provides a UI for configuring a character's equipment, enhancements,
//   crystals and gacha bonuses, calculates aggregated stats, and allows
//   saving/loading builds to local storage (web) or an in-memory fallback.
// -----------------------------------------------------------------------------

class BuildSimulatorScreen extends StatefulWidget {
  const BuildSimulatorScreen({super.key});

  @override
  State<BuildSimulatorScreen> createState() => _BuildSimulatorScreenState();
}

// ---------------------------------------------------------------------------
// Navigation widgets are now imported from lib/widgets/navigation/
// ---------------------------------------------------------------------------

class _BuildSimulatorScreenState extends State<BuildSimulatorScreen> {
  // ---------------------------
  // State: Character & Build
  // ---------------------------
  // Character base stats and special stat container
  final CharacterStats _character = CharacterStats();

  // Equipment selection (ids reference entries in EquipmentData)
  String? _mainWeaponId;
  String? _subWeaponId;
  String? _armorId;
  String? _helmetId;
  String? _ringId;

  // Enhancement levels per equipment slot
  int _enhMain = 0;
  int _enhSub = 0;
  int _enhArmor = 0;
  int _enhHelmet = 0;
  int _enhRing = 0;

  // Crystals (two slots where applicable)
  String? _mainCrystal1;
  String? _mainCrystal2;

  String? _armorCrystal1;
  String? _armorCrystal2;

  String? _helmetCrystal1;
  String? _helmetCrystal2;

  String? _ringCrystal1;
  String? _ringCrystal2;

  // Gacha selections (3 gacha items, each with up to 3 stat choices)
  String? _gacha1Stat1;
  String? _gacha1Stat2;
  String? _gacha1Stat3;

  String? _gacha2Stat1;
  String? _gacha2Stat2;
  String? _gacha2Stat3;

  String? _gacha3Stat1;
  String? _gacha3Stat2;
  String? _gacha3Stat3;

  // Save / load UI and storage cache
  final TextEditingController _buildNameController = TextEditingController();
  List<Map<String, dynamic>> _savedBuilds = <Map<String, dynamic>>[];

  // Calculated summary and human-readable recommendations
  Map<String, num> _summary = <String, num>{};
  List<String> _recommendations = <String>[];

  // Collapse/Expand state for each card
  bool _isCharacterStatsExpanded = true;
  bool _isMainWeaponExpanded = true;
  bool _isSubWeaponExpanded = true;
  bool _isArmorExpanded = true;
  bool _isHelmetExpanded = true;
  bool _isRingExpanded = true;
  bool _isGachaExpanded = true;

  // Navigation rail state
  final GlobalKey<CustomNavigationRailState> _navRailKey =
      GlobalKey<CustomNavigationRailState>();

  @override
  void initState() {
    super.initState();
    _loadSavedBuilds();
    _recalculateAll();
  }

  @override
  void dispose() {
    _buildNameController.dispose();
    super.dispose();
  }

  void _loadSavedBuilds() {
    // ---------------------------
    // Storage: load saved builds
    // Uses `getLocalStorageItem` which is a cross-platform abstraction:
    // - On web it forwards to `window.localStorage`
    // - On other platforms it uses an in-memory fallback
    // ---------------------------
    try {
      final raw = getLocalStorageItem('toramBuilds');
      if (raw == null || raw.isEmpty) {
        _savedBuilds = <Map<String, dynamic>>[];
        return;
      }
      final list = jsonDecode(raw);
      final result = <Map<String, dynamic>>[];
      if (list is List) {
        for (int i = 0; i < list.length; i++) {
          final item = list[i];
          if (item is Map<String, dynamic>) {
            result.add(item);
          } else if (item is Map) {
            result.add(item.cast<String, dynamic>());
          }
        }
      }
      _savedBuilds = result;
    } catch (_) {
      _savedBuilds = <Map<String, dynamic>>[];
    }
  }

  void _saveBuildsToStorage() {
    // ---------------------------
    // Storage: persist saved builds
    // ---------------------------
    final raw = jsonEncode(_savedBuilds);
    setLocalStorageItem('toramBuilds', raw);
  }

  void _recalculateAll() {
    // Only recalculate if needed - avoid unnecessary computation
    final newSummary = _calculateSummary();
    final newRecommendations = _buildRecommendations();

    // Check if values actually changed before calling setState
    bool summaryChanged = false;
    if (_summary.length != newSummary.length) {
      summaryChanged = true;
    } else {
      for (final key in newSummary.keys) {
        if (_summary[key] != newSummary[key]) {
          summaryChanged = true;
          break;
        }
      }
    }

    if (summaryChanged ||
        _recommendations.length != newRecommendations.length) {
      _summary = newSummary;
      _recommendations = newRecommendations;
      setState(() {});
    }
  }

  // ---------------------------
  // Calculation: summary & helpers
  // - Compute aggregated stats from character, equipment, crystals and gacha
  // - Provide mapping helpers and recommendation builder
  // ---------------------------

  Map<String, num> _emptySummary() {
    return <String, num>{
      'ATK': 0,
      'MATK': 0,
      'DEF': 0,
      'MDEF': 0,
      'ASPD': 0,
      'CritRate': 0,
      'PhysicalPierce': 0,
      'ElementPierce': 0,
      'Accuracy': 0,
      'Stability': 0,
      'HP': 0,
      'MP': 0,
    };
  }

  Map<String, num> _calculateSummary() {
    final result = _emptySummary();

    // base main stats from character
    result['STR'] = _character.str;
    result['DEX'] = _character.dex;
    result['INT'] = _character.intStat;
    result['AGI'] = _character.agi;
    result['VIT'] = _character.vit;

    result['ATK'] = 0;
    result['MATK'] = 0;
    result['DEF'] = 0;
    result['MDEF'] = 0;
    result['ASPD'] = 0;
    result['CritRate'] = 0;
    result['PhysicalPierce'] = 0;
    result['ElementPierce'] = 0;
    result['Accuracy'] = 0;
    result['Stability'] = 0;
    result['HP'] = 0;
    result['MP'] = 0;

    // helper to add stats from equipment item with enhancement
    void addEquip(String? id, int enh) {
      final item = EquipmentData.findItem(id);
      if (item == null) return;

      final factor = 0.1 * enh;
      int addWithEnh(int base) {
        if (base == 0 || enh == 0) return base;
        final extra = (base * factor).floor();
        return base + extra;
      }

      result['ATK'] = (result['ATK'] ?? 0) + addWithEnh(item.atk);
      result['MATK'] = (result['MATK'] ?? 0) + addWithEnh(item.matk);
      result['DEF'] = (result['DEF'] ?? 0) + addWithEnh(item.def);
      result['MDEF'] = (result['MDEF'] ?? 0) + addWithEnh(item.mdef);
      result['STR'] = (result['STR'] ?? 0) + addWithEnh(item.str);
      result['DEX'] = (result['DEX'] ?? 0) + addWithEnh(item.dex);
      result['INT'] = (result['INT'] ?? 0) + addWithEnh(item.intStat);
      result['AGI'] = (result['AGI'] ?? 0) + addWithEnh(item.agi);
      result['VIT'] = (result['VIT'] ?? 0) + addWithEnh(item.vit);
      result['ASPD'] = (result['ASPD'] ?? 0) + addWithEnh(item.aspd);
      result['CritRate'] =
          (result['CritRate'] ?? 0) + addWithEnh(item.critRate);
      result['Accuracy'] =
          (result['Accuracy'] ?? 0) + addWithEnh(item.accuracy);
      result['Stability'] =
          (result['Stability'] ?? 0) + addWithEnh(item.stability);
      result['PhysicalPierce'] =
          (result['PhysicalPierce'] ?? 0) + addWithEnh(item.physicalPierce);
      result['ElementPierce'] =
          (result['ElementPierce'] ?? 0) + addWithEnh(item.elementPierce);
      result['HP'] = (result['HP'] ?? 0) + addWithEnh(item.hp);
      result['MP'] = (result['MP'] ?? 0) + addWithEnh(item.mp);
    }

    addEquip(_mainWeaponId, _enhMain);
    addEquip(_subWeaponId, _enhSub);
    addEquip(_armorId, _enhArmor);
    addEquip(_helmetId, _enhHelmet);
    addEquip(_ringId, _enhRing);

    // crystals
    void addCrystal(String? id) {
      if (id == null || id.isEmpty) return;
      final c = EquipmentData.findCrystal(id);
      if (c == null) return;
      c.stats.forEach((key, value) {
        final upper = _statKeyToSummaryKey(key);
        if (upper.isEmpty) return;
        result[upper] = (result[upper] ?? 0) + value;
      });
    }

    addCrystal(_mainCrystal1);
    addCrystal(_mainCrystal2);
    addCrystal(_armorCrystal1);
    addCrystal(_armorCrystal2);
    addCrystal(_helmetCrystal1);
    addCrystal(_helmetCrystal2);
    addCrystal(_ringCrystal1);
    addCrystal(_ringCrystal2);

    // base copy before gacha percent
    final baseBeforeGacha = Map<String, num>.from(result);

    void addGacha(String? id) {
      if (id == null || id.isEmpty) return;
      final g = EquipmentData.findGacha(id);
      if (g == null) return;

      final key = _statKeyToSummaryKey(g.stat);
      if (key.isEmpty) return;

      if (g.type == 'percent') {
        final base = baseBeforeGacha[key] ?? 0;
        final add = (base * g.value / 100).floor();
        result[key] = (result[key] ?? 0) + add;
      } else {
        result[key] = (result[key] ?? 0) + g.value;
      }
    }

    addGacha(_gacha1Stat1);
    addGacha(_gacha1Stat2);
    addGacha(_gacha1Stat3);
    addGacha(_gacha2Stat1);
    addGacha(_gacha2Stat2);
    addGacha(_gacha2Stat3);
    addGacha(_gacha3Stat1);
    addGacha(_gacha3Stat2);
    addGacha(_gacha3Stat3);

    // small hp bonus from VIT so ui is less zero
    final vitVal = result['VIT'] ?? 0;
    result['HP'] = (result['HP'] ?? 0) + vitVal * 20;

    return result;
  }

  // Note: the calculation functions intentionally use integer arithmetic and
  // floor operations for percent-based bonuses to reflect how in-game stats
  // are typically computed. Keep the helper `addWithEnh` logic in sync with
  // any UI presentation of enhanced values.

  String _statKeyToSummaryKey(String raw) {
    if (raw == 'atk') return 'ATK';
    if (raw == 'matk') return 'MATK';
    if (raw == 'def') return 'DEF';
    if (raw == 'mdef') return 'MDEF';
    if (raw == 'aspd') return 'ASPD';
    if (raw == 'crit_rate') return 'CritRate';
    if (raw == 'physical_pierce') return 'PhysicalPierce';
    if (raw == 'element_pierce') return 'ElementPierce';
    if (raw == 'accuracy') return 'Accuracy';
    if (raw == 'stability') return 'Stability';
    if (raw == 'hp') return 'HP';
    if (raw == 'mp') return 'MP';
    if (raw == 'str') return 'STR';
    if (raw == 'dex') return 'DEX';
    if (raw == 'intStat') return 'INT';
    if (raw == 'agi') return 'AGI';
    if (raw == 'vit') return 'VIT';
    return '';
  }

  List<String> _buildRecommendations() {
    final list = <String>[];

    final atk = _summary['ATK'] ?? 0;
    final matk = _summary['MATK'] ?? 0;
    final defVal = _summary['DEF'] ?? 0;
    final hpVal = _summary['HP'] ?? 0;
    final crit = _summary['CritRate'] ?? 0;

    if (atk == 0 && matk == 0) {
      list.add(
        'เลือก Main Weapon ก่อน เพื่อเริ่มต้นวางโครงสร้าง Build ของตัวละคร',
      );
    } else if (atk >= matk) {
      list.add(
        'ตรวจพบสาย Physical! โฟกัส STR และ DEX เพื่อดาเมจสูงสุด และอาจเพิ่ม Critical Rate',
      );
    } else {
      list.add(
        'ตรวจพบสาย Magic! ลองเพิ่ม INT และ MP รวมถึง MATK เพื่อดาเมจเวทย์ที่แรงขึ้น',
      );
    }

    if (crit < 10) {
      list.add(
        'Critical Rate ยังไม่สูง ลองใส่ Crystal หรือ Gacha เพิ่มค่า Critical จะช่วยให้ดาเมจเสถียรขึ้น',
      );
    } else {
      list.add(
        'Critical Rate อยู่ในระดับดี สามารถเน้นเสริม Critical Damage หรือ ATK% ต่อได้',
      );
    }

    if (defVal < 100 && hpVal < 500) {
      list.add(
        'ค่าป้องกันกับ HP ยังไม่มาก เพิ่ม Armor / VIT / Crystal สายป้องกันจะช่วยให้รอดตายในบอสยาก ๆ ได้ง่ายขึ้น',
      );
    } else {
      list.add(
        'พลังป้องกันค่อนข้างดี สามารถโฟกัสการเพิ่มดาเมจและความเร็วโจมตีเพิ่มเติมได้',
      );
    }

    return list;
  }

  // ---------------------------
  // Build persistence & small helpers
  // - Save / Load / Delete builds and UI snack helper
  // ---------------------------

  void _onSaveBuild() {
    final name = _buildNameController.text.trim();
    if (name.isEmpty) {
      _showSnack('กรุณาตั้งชื่อ Build ก่อน');
      return;
    }

    final data = <String, dynamic>{
      'name': name,
      'character': _character.toJson(),
      'equip': {
        'main': _mainWeaponId,
        'sub': _subWeaponId,
        'armor': _armorId,
        'helmet': _helmetId,
        'ring': _ringId,
      },
      'enh': {
        'main': _enhMain,
        'sub': _enhSub,
        'armor': _enhArmor,
        'helmet': _enhHelmet,
        'ring': _enhRing,
      },
      'crystal': {
        'main1': _mainCrystal1,
        'main2': _mainCrystal2,
        'armor1': _armorCrystal1,
        'armor2': _armorCrystal2,
        'helmet1': _helmetCrystal1,
        'helmet2': _helmetCrystal2,
        'ring1': _ringCrystal1,
        'ring2': _ringCrystal2,
      },
      'gacha': {
        'g1s1': _gacha1Stat1,
        'g1s2': _gacha1Stat2,
        'g1s3': _gacha1Stat3,
        'g2s1': _gacha2Stat1,
        'g2s2': _gacha2Stat2,
        'g2s3': _gacha2Stat3,
        'g3s1': _gacha3Stat1,
        'g3s2': _gacha3Stat2,
        'g3s3': _gacha3Stat3,
      },
    };

    _savedBuilds.add(data);
    _saveBuildsToStorage();
    _buildNameController.clear();
    _recalculateAll();
    _showSnack('บันทึก Build "$name" แล้ว (Local Storage)');
  }

  void _onLoadBuild(int index) {
    if (index < 0 || index >= _savedBuilds.length) return;
    final data = _savedBuilds[index];

    try {
      final charJson = data['character'] as Map<String, dynamic>;
      final equipJson = data['equip'] as Map<String, dynamic>;
      final enhJson = data['enh'] as Map<String, dynamic>;
      final cryJson = data['crystal'] as Map<String, dynamic>;
      final gachaJson = data['gacha'] as Map<String, dynamic>;

      final restored = CharacterStats.fromJson(charJson);
      _character.str = restored.str;
      _character.intStat = restored.intStat;
      _character.vit = restored.vit;
      _character.agi = restored.agi;
      _character.dex = restored.dex;
      _character.specialType = restored.specialType;
      _character.specialValue = restored.specialValue;

      _mainWeaponId = equipJson['main'] as String?;
      _subWeaponId = equipJson['sub'] as String?;
      _armorId = equipJson['armor'] as String?;
      _helmetId = equipJson['helmet'] as String?;
      _ringId = equipJson['ring'] as String?;

      _enhMain = enhJson['main'] ?? 0;
      _enhSub = enhJson['sub'] ?? 0;
      _enhArmor = enhJson['armor'] ?? 0;
      _enhHelmet = enhJson['helmet'] ?? 0;
      _enhRing = enhJson['ring'] ?? 0;

      _mainCrystal1 = cryJson['main1'] as String?;
      _mainCrystal2 = cryJson['main2'] as String?;

      _armorCrystal1 = cryJson['armor1'] as String?;
      _armorCrystal2 = cryJson['armor2'] as String?;

      _helmetCrystal1 = cryJson['helmet1'] as String?;
      _helmetCrystal2 = cryJson['helmet2'] as String?;

      _ringCrystal1 = cryJson['ring1'] as String?;
      _ringCrystal2 = cryJson['ring2'] as String?;

      _gacha1Stat1 = gachaJson['g1s1'] as String?;
      _gacha1Stat2 = gachaJson['g1s2'] as String?;
      _gacha1Stat3 = gachaJson['g1s3'] as String?;

      _gacha2Stat1 = gachaJson['g2s1'] as String?;
      _gacha2Stat2 = gachaJson['g2s2'] as String?;
      _gacha2Stat3 = gachaJson['g2s3'] as String?;

      _gacha3Stat1 = gachaJson['g3s1'] as String?;
      _gacha3Stat2 = gachaJson['g3s2'] as String?;
      _gacha3Stat3 = gachaJson['g3s3'] as String?;

      _recalculateAll();
      _showSnack('โหลด Build "${data['name']}" แล้ว');
    } catch (e) {
      _showSnack('โหลด Build ล้มเหลว');
    }
  }

  void _onDeleteBuild(int index) {
    if (index < 0 || index >= _savedBuilds.length) return;
    final name = _savedBuilds[index]['name'] ?? '';
    _savedBuilds.removeAt(index);
    _saveBuildsToStorage();
    _recalculateAll();
    _showSnack('ลบ Build "$name" แล้ว');
  }

  void _onClearAll() {
    _character.str = 1;
    _character.intStat = 1;
    _character.vit = 1;
    _character.agi = 1;
    _character.dex = 1;
    _character.specialType = '';
    _character.specialValue = 1;

    _mainWeaponId = null;
    _subWeaponId = null;
    _armorId = null;
    _helmetId = null;
    _ringId = null;

    _enhMain = 0;
    _enhSub = 0;
    _enhArmor = 0;
    _enhHelmet = 0;
    _enhRing = 0;

    _mainCrystal1 = null;
    _mainCrystal2 = null;
    _armorCrystal1 = null;
    _armorCrystal2 = null;
    _helmetCrystal1 = null;
    _helmetCrystal2 = null;
    _ringCrystal1 = null;
    _ringCrystal2 = null;

    _gacha1Stat1 = null;
    _gacha1Stat2 = null;
    _gacha1Stat3 = null;
    _gacha2Stat1 = null;
    _gacha2Stat2 = null;
    _gacha2Stat3 = null;
    _gacha3Stat1 = null;
    _gacha3Stat2 = null;
    _gacha3Stat3 = null;

    _buildNameController.clear();
    _recalculateAll();
    _showSnack('ล้างค่าทั้งหมดแล้ว');
  }

  void _showSnack(String msg) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ---------------------------
  // UI: Main scaffold & layout
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;

        Widget body;
        if (isWide) {
          // Desktop: NavigationRail on left, sidebar on right
          body = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNavigationRail(key: _navRailKey, initialIndex: 0),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildEquipmentPanel(),
                ),
              ),
              SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                  child: Column(
                    children: [
                      _buildStatsSummary(),
                      const SizedBox(height: 24),
                      _buildRecommendationsSection(),
                      const SizedBox(height: 24),
                      _buildSaveLoadSection(),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile: only show equipment panel, endDrawer on right
          body = SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildEquipmentPanel(),
          );
        }

        return Scaffold(
          appBar: _buildHeader(),
          endDrawer: isWide ? null : _buildMobileDrawer(),
          body: body,
          bottomNavigationBar:
              isWide ? null : const CustomBottomNavigationBar(initialIndex: 0),
        );
      },
    );
  }

  PreferredSizeWidget _buildHeader() {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.primaryColor,
      elevation: 4,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = MediaQuery.of(context).size.width >= 1024;
                // Show menu button only on desktop
                if (!isWide) return const SizedBox.shrink();

                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    _navRailKey.currentState?.toggleExtended();
                  },
                  tooltip: 'Menu',
                );
              },
            ),
            const SizedBox(width: 8),
            const Image(
              image: AssetImage('assets/icon/Logo.png'),
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'Toram Item Build Simulation',
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

  Widget _buildMobileDrawer() {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return Drawer(
      backgroundColor: customColors?.cardBackground ?? theme.cardColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            // Stats Summary, Recommendations, and Save/Load
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsSummary(),
                    const SizedBox(height: 24),
                    _buildRecommendationsSection(),
                    const SizedBox(height: 24),
                    _buildSaveLoadSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // UI: Collapsible Card Helper
  // ---------------------------

  Widget _buildCollapsibleCard({
    required String title,
    required String icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    double? height,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10A37F).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF10A37F).withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10A37F),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF10A37F),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Flexible(
              child: ConstrainedBox(
                constraints: height != null
                    ? BoxConstraints(maxHeight: height)
                    : const BoxConstraints(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------
  // UI: Equipment panel builders
  // - _buildEquipmentPanel, _buildCharacterStatsCard, item cards, helpers
  // ---------------------------

  Widget _buildEquipmentPanel() {
    return ToramCard(
      title: 'Equipment Configuration',
      icon: Icons.shield,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    SizedBox(
                      width: (constraints.maxWidth - 20) / 2,
                      child: _buildCollapsibleCard(
                        title: 'Character Stats',
                        icon: '👤',
                        isExpanded: _isCharacterStatsExpanded,
                        onToggle: () {
                          setState(() {
                            _isCharacterStatsExpanded =
                                !_isCharacterStatsExpanded;
                          });
                        },
                        child: CharacterStatsCard(
                          character: _character,
                          onStatsChanged: _recalculateAll,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (constraints.maxWidth - 20) / 2,
                      child: _buildCollapsibleCard(
                        title: 'Main Weapon',
                        icon: '⚔️',
                        isExpanded: _isMainWeaponExpanded,
                        onToggle: () {
                          setState(() {
                            _isMainWeaponExpanded = !_isMainWeaponExpanded;
                          });
                        },
                        height: 615,
                        child: MainWeaponSelector(
                          selectedId: _mainWeaponId,
                          onEquipChanged: (id) {
                            setState(() {
                              _mainWeaponId = id;
                              _recalculateAll();
                            });
                          },
                          enhance: _enhMain,
                          onEnhChanged: (v) {
                            setState(() {
                              _enhMain = v;
                              _recalculateAll();
                            });
                          },
                          crystal1: _mainCrystal1,
                          crystal2: _mainCrystal2,
                          onCrystal1Changed: (v) {
                            setState(() {
                              _mainCrystal1 = v;
                              _recalculateAll();
                            });
                          },
                          onCrystal2Changed: (v) {
                            setState(() {
                              _mainCrystal2 = v;
                              _recalculateAll();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (constraints.maxWidth - 20) / 2,
                      child: _buildCollapsibleCard(
                        title: 'Sub Weapon',
                        icon: '🛡️',
                        isExpanded: _isSubWeaponExpanded,
                        onToggle: () {
                          setState(() {
                            _isSubWeaponExpanded = !_isSubWeaponExpanded;
                          });
                        },
                        height: 440,
                        child: SubWeaponSelector(
                          selectedId: _subWeaponId,
                          onEquipChanged: (id) {
                            setState(() {
                              _subWeaponId = id;
                              _recalculateAll();
                            });
                          },
                          enhance: _enhSub,
                          onEnhChanged: (v) {
                            setState(() {
                              _enhSub = v;
                              _recalculateAll();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (constraints.maxWidth - 20) / 2,
                      child: _buildCollapsibleCard(
                        title: 'Armor',
                        icon: '🛡️',
                        isExpanded: _isArmorExpanded,
                        onToggle: () {
                          setState(() {
                            _isArmorExpanded = !_isArmorExpanded;
                          });
                        },
                        height: 615,
                        child: ArmorSelector(
                          selectedId: _armorId,
                          onEquipChanged: (id) {
                            setState(() {
                              _armorId = id;
                              _recalculateAll();
                            });
                          },
                          enhance: _enhArmor,
                          onEnhChanged: (v) {
                            setState(() {
                              _enhArmor = v;
                              _recalculateAll();
                            });
                          },
                          crystal1: _armorCrystal1,
                          crystal2: _armorCrystal2,
                          onCrystal1Changed: (v) {
                            setState(() {
                              _armorCrystal1 = v;
                              _recalculateAll();
                            });
                          },
                          onCrystal2Changed: (v) {
                            setState(() {
                              _armorCrystal2 = v;
                              _recalculateAll();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (constraints.maxWidth - 20) / 2,
                      child: _buildCollapsibleCard(
                        title: 'Helmet',
                        icon: '🎩',
                        isExpanded: _isHelmetExpanded,
                        onToggle: () {
                          setState(() {
                            _isHelmetExpanded = !_isHelmetExpanded;
                          });
                        },
                        height: 615,
                        child: HelmetSelector(
                          selectedId: _helmetId,
                          onEquipChanged: (id) {
                            setState(() {
                              _helmetId = id;
                              _recalculateAll();
                            });
                          },
                          enhance: _enhHelmet,
                          onEnhChanged: (v) {
                            setState(() {
                              _enhHelmet = v;
                              _recalculateAll();
                            });
                          },
                          crystal1: _helmetCrystal1,
                          crystal2: _helmetCrystal2,
                          onCrystal1Changed: (v) {
                            setState(() {
                              _helmetCrystal1 = v;
                              _recalculateAll();
                            });
                          },
                          onCrystal2Changed: (v) {
                            setState(() {
                              _helmetCrystal2 = v;
                              _recalculateAll();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (constraints.maxWidth - 20) / 2,
                      child: _buildCollapsibleCard(
                        title: 'Ring',
                        icon: '💍',
                        isExpanded: _isRingExpanded,
                        onToggle: () {
                          setState(() {
                            _isRingExpanded = !_isRingExpanded;
                          });
                        },
                        height: 615,
                        child: RingSelector(
                          selectedId: _ringId,
                          onEquipChanged: (id) {
                            setState(() {
                              _ringId = id;
                              _recalculateAll();
                            });
                          },
                          enhance: _enhRing,
                          onEnhChanged: (v) {
                            setState(() {
                              _enhRing = v;
                              _recalculateAll();
                            });
                          },
                          crystal1: _ringCrystal1,
                          crystal2: _ringCrystal2,
                          onCrystal1Changed: (v) {
                            setState(() {
                              _ringCrystal1 = v;
                              _recalculateAll();
                            });
                          },
                          onCrystal2Changed: (v) {
                            setState(() {
                              _ringCrystal2 = v;
                              _recalculateAll();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: _buildCollapsibleCard(
                        title: 'Gacha Equipment',
                        icon: '🎰',
                        isExpanded: _isGachaExpanded,
                        onToggle: () {
                          setState(() {
                            _isGachaExpanded = !_isGachaExpanded;
                          });
                        },
                        child: GachaCard(
                          gacha1Stat1: _gacha1Stat1,
                          gacha1Stat2: _gacha1Stat2,
                          gacha1Stat3: _gacha1Stat3,
                          gacha2Stat1: _gacha2Stat1,
                          gacha2Stat2: _gacha2Stat2,
                          gacha2Stat3: _gacha2Stat3,
                          gacha3Stat1: _gacha3Stat1,
                          gacha3Stat2: _gacha3Stat2,
                          gacha3Stat3: _gacha3Stat3,
                          onGacha1Stat1Changed: (v) {
                            setState(() {
                              _gacha1Stat1 = v;
                              _recalculateAll();
                            });
                          },
                          onGacha1Stat2Changed: (v) {
                            setState(() {
                              _gacha1Stat2 = v;
                              _recalculateAll();
                            });
                          },
                          onGacha1Stat3Changed: (v) {
                            setState(() {
                              _gacha1Stat3 = v;
                              _recalculateAll();
                            });
                          },
                          onGacha2Stat1Changed: (v) {
                            setState(() {
                              _gacha2Stat1 = v;
                              _recalculateAll();
                            });
                          },
                          onGacha2Stat2Changed: (v) {
                            setState(() {
                              _gacha2Stat2 = v;
                              _recalculateAll();
                            });
                          },
                          onGacha2Stat3Changed: (v) {
                            setState(() {
                              _gacha2Stat3 = v;
                              _recalculateAll();
                            });
                          },
                          onGacha3Stat1Changed: (v) {
                            setState(() {
                              _gacha3Stat1 = v;
                              _recalculateAll();
                            });
                          },
                          onGacha3Stat2Changed: (v) {
                            setState(() {
                              _gacha3Stat2 = v;
                              _recalculateAll();
                            });
                          },
                          onGacha3Stat3Changed: (v) {
                            setState(() {
                              _gacha3Stat3 = v;
                              _recalculateAll();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildCollapsibleCard(
                    title: 'Character Stats',
                    icon: '👤',
                    isExpanded: _isCharacterStatsExpanded,
                    onToggle: () {
                      setState(() {
                        _isCharacterStatsExpanded = !_isCharacterStatsExpanded;
                      });
                    },
                    child: CharacterStatsCard(
                      character: _character,
                      onStatsChanged: _recalculateAll,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCollapsibleCard(
                    title: 'Main Weapon',
                    icon: '⚔️',
                    isExpanded: _isMainWeaponExpanded,
                    onToggle: () {
                      setState(() {
                        _isMainWeaponExpanded = !_isMainWeaponExpanded;
                      });
                    },
                    child: MainWeaponSelector(
                      selectedId: _mainWeaponId,
                      onEquipChanged: (id) {
                        setState(() {
                          _mainWeaponId = id;
                          _recalculateAll();
                        });
                      },
                      enhance: _enhMain,
                      onEnhChanged: (v) {
                        setState(() {
                          _enhMain = v;
                          _recalculateAll();
                        });
                      },
                      crystal1: _mainCrystal1,
                      crystal2: _mainCrystal2,
                      onCrystal1Changed: (v) {
                        setState(() {
                          _mainCrystal1 = v;
                          _recalculateAll();
                        });
                      },
                      onCrystal2Changed: (v) {
                        setState(() {
                          _mainCrystal2 = v;
                          _recalculateAll();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCollapsibleCard(
                    title: 'Sub Weapon',
                    icon: '🛡️',
                    isExpanded: _isSubWeaponExpanded,
                    onToggle: () {
                      setState(() {
                        _isSubWeaponExpanded = !_isSubWeaponExpanded;
                      });
                    },
                    child: SubWeaponSelector(
                      selectedId: _subWeaponId,
                      onEquipChanged: (id) {
                        setState(() {
                          _subWeaponId = id;
                          _recalculateAll();
                        });
                      },
                      enhance: _enhSub,
                      onEnhChanged: (v) {
                        setState(() {
                          _enhSub = v;
                          _recalculateAll();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCollapsibleCard(
                    title: 'Armor',
                    icon: '🛡️',
                    isExpanded: _isArmorExpanded,
                    onToggle: () {
                      setState(() {
                        _isArmorExpanded = !_isArmorExpanded;
                      });
                    },
                    child: ArmorSelector(
                      selectedId: _armorId,
                      onEquipChanged: (id) {
                        setState(() {
                          _armorId = id;
                          _recalculateAll();
                        });
                      },
                      enhance: _enhArmor,
                      onEnhChanged: (v) {
                        setState(() {
                          _enhArmor = v;
                          _recalculateAll();
                        });
                      },
                      crystal1: _armorCrystal1,
                      crystal2: _armorCrystal2,
                      onCrystal1Changed: (v) {
                        setState(() {
                          _armorCrystal1 = v;
                          _recalculateAll();
                        });
                      },
                      onCrystal2Changed: (v) {
                        setState(() {
                          _armorCrystal2 = v;
                          _recalculateAll();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCollapsibleCard(
                    title: 'Helmet',
                    icon: '🎩',
                    isExpanded: _isHelmetExpanded,
                    onToggle: () {
                      setState(() {
                        _isHelmetExpanded = !_isHelmetExpanded;
                      });
                    },
                    child: HelmetSelector(
                      selectedId: _helmetId,
                      onEquipChanged: (id) {
                        setState(() {
                          _helmetId = id;
                          _recalculateAll();
                        });
                      },
                      enhance: _enhHelmet,
                      onEnhChanged: (v) {
                        setState(() {
                          _enhHelmet = v;
                          _recalculateAll();
                        });
                      },
                      crystal1: _helmetCrystal1,
                      crystal2: _helmetCrystal2,
                      onCrystal1Changed: (v) {
                        setState(() {
                          _helmetCrystal1 = v;
                          _recalculateAll();
                        });
                      },
                      onCrystal2Changed: (v) {
                        setState(() {
                          _helmetCrystal2 = v;
                          _recalculateAll();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCollapsibleCard(
                    title: 'Ring',
                    icon: '💍',
                    isExpanded: _isRingExpanded,
                    onToggle: () {
                      setState(() {
                        _isRingExpanded = !_isRingExpanded;
                      });
                    },
                    child: RingSelector(
                      selectedId: _ringId,
                      onEquipChanged: (id) {
                        setState(() {
                          _ringId = id;
                          _recalculateAll();
                        });
                      },
                      enhance: _enhRing,
                      onEnhChanged: (v) {
                        setState(() {
                          _enhRing = v;
                          _recalculateAll();
                        });
                      },
                      crystal1: _ringCrystal1,
                      crystal2: _ringCrystal2,
                      onCrystal1Changed: (v) {
                        setState(() {
                          _ringCrystal1 = v;
                          _recalculateAll();
                        });
                      },
                      onCrystal2Changed: (v) {
                        setState(() {
                          _ringCrystal2 = v;
                          _recalculateAll();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCollapsibleCard(
                    title: 'Gacha Equipment',
                    icon: '🎰',
                    isExpanded: _isGachaExpanded,
                    onToggle: () {
                      setState(() {
                        _isGachaExpanded = !_isGachaExpanded;
                      });
                    },
                    child: GachaCard(
                      gacha1Stat1: _gacha1Stat1,
                      gacha1Stat2: _gacha1Stat2,
                      gacha1Stat3: _gacha1Stat3,
                      gacha2Stat1: _gacha2Stat1,
                      gacha2Stat2: _gacha2Stat2,
                      gacha2Stat3: _gacha2Stat3,
                      gacha3Stat1: _gacha3Stat1,
                      gacha3Stat2: _gacha3Stat2,
                      gacha3Stat3: _gacha3Stat3,
                      onGacha1Stat1Changed: (v) {
                        setState(() {
                          _gacha1Stat1 = v;
                          _recalculateAll();
                        });
                      },
                      onGacha1Stat2Changed: (v) {
                        setState(() {
                          _gacha1Stat2 = v;
                          _recalculateAll();
                        });
                      },
                      onGacha1Stat3Changed: (v) {
                        setState(() {
                          _gacha1Stat3 = v;
                          _recalculateAll();
                        });
                      },
                      onGacha2Stat1Changed: (v) {
                        setState(() {
                          _gacha2Stat1 = v;
                          _recalculateAll();
                        });
                      },
                      onGacha2Stat2Changed: (v) {
                        setState(() {
                          _gacha2Stat2 = v;
                          _recalculateAll();
                        });
                      },
                      onGacha2Stat3Changed: (v) {
                        setState(() {
                          _gacha2Stat3 = v;
                          _recalculateAll();
                        });
                      },
                      onGacha3Stat1Changed: (v) {
                        setState(() {
                          _gacha3Stat1 = v;
                          _recalculateAll();
                        });
                      },
                      onGacha3Stat2Changed: (v) {
                        setState(() {
                          _gacha3Stat2 = v;
                          _recalculateAll();
                        });
                      },
                      onGacha3Stat3Changed: (v) {
                        setState(() {
                          _gacha3Stat3 = v;
                          _recalculateAll();
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Desktop sidebar removed - content moved to mobile drawer only

  // ---------------------------
  // UI: Sidebar (stats summary, recommendations, save/load)
  // ---------------------------

  Widget _sectionTitle(IconData iconData, String title) {
    return Row(
      children: [
        Icon(iconData, color: const Color(0xFF10A37F), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF10A37F),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10A37F).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.assessment, 'Stats Summary'),
          const SizedBox(height: 20),
          _statsCategory(Icons.gavel, 'Attack', <MapEntry<String, String>>[
            MapEntry('ATK', 'ATK'),
            MapEntry('MATK', 'MATK'),
          ]),
          _statsCategory(Icons.shield, 'Defense', <MapEntry<String, String>>[
            MapEntry('DEF', 'DEF'),
            MapEntry('MDEF', 'MDEF'),
          ]),
          _statsCategory(
              Icons.fitness_center, 'Main Stats', <MapEntry<String, String>>[
            MapEntry('STR', 'STR'),
            MapEntry('DEX', 'DEX'),
            MapEntry('INT', 'INT'),
            MapEntry('AGI', 'AGI'),
            MapEntry('VIT', 'VIT'),
          ]),
          _statsCategory(
              Icons.bolt, 'Special Stats', <MapEntry<String, String>>[
            MapEntry('ASPD', 'ASPD'),
            MapEntry('CritRate', 'Critical Rate'),
            MapEntry('PhysicalPierce', 'Piercing (Physical)'),
            MapEntry('ElementPierce', 'Piercing (Element)'),
            MapEntry('Accuracy', 'Accuracy'),
            MapEntry('Stability', 'Stability'),
            MapEntry('HP', 'HP'),
            MapEntry('MP', 'MP'),
          ]),
        ],
      ),
    );
  }

  Widget _statsCategory(
    IconData iconData,
    String title,
    List<MapEntry<String, String>> rows,
  ) {
    final children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      final key = rows[i].key;
      final label = rows[i].value;
      num value = _summary[key] ?? 0;
      String display;
      if (label.contains('%') ||
          key == 'CritRate' ||
          key == 'Accuracy' ||
          key == 'Stability') {
        display = '${value.toInt()}%';
      } else {
        display = value.toInt().toString();
      }
      children.add(_statRow(label, display));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: const Color(0xFF10A37F), size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10A37F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0x4410A37F), width: 1),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x22FFFFFF), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF10A37F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final children = <Widget>[];
    for (int i = 0; i < _recommendations.length; i++) {
      children.add(
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF10A37F).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: const Border(
              left: BorderSide(color: Color(0xFF10A37F), width: 3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1}.',
                style: const TextStyle(
                  color: Color(0xFF10A37F),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _recommendations[i],
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10A37F).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.lightbulb, 'AI Recommendations'),
          const SizedBox(height: 16),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildSaveLoadSection() {
    final savedWidgets = <Widget>[];
    for (int i = 0; i < _savedBuilds.length; i++) {
      final name = _savedBuilds[i]['name'] ?? 'Build ${i + 1}';
      savedWidgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: const Color(0xFF10A37F).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => _onLoadBuild(i),
                child: const Text('Load', style: TextStyle(fontSize: 11)),
              ),
              TextButton(
                onPressed: () => _onDeleteBuild(i),
                child: const Text(
                  '×',
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10A37F).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.save, 'Save / Load Build'),
          const SizedBox(height: 16),
          TextField(
            controller: _buildNameController,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter build name...',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: const Color(0xFF10A37F).withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10A37F)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child:
                    _gradientButton(label: 'Save Build', onTap: _onSaveBuild),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _gradientButton(
                  label: 'Clear All',
                  isSecondary: true,
                  onTap: _onClearAll,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: SingleChildScrollView(child: Column(children: savedWidgets)),
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isSecondary
              ? const LinearGradient(
                  colors: [Color(0xFF6c757d), Color(0xFF5a6268)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF10A37F), Color(0xFF0d8a6b)],
                ),
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
