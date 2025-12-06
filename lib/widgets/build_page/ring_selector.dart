import 'package:flutter/material.dart';
import '../../models/equipment_data.dart';

/// RingSelector - Widget for selecting and configuring ring
///
/// This widget provides:
/// - Dropdown for selecting ring from available items
/// - Enhancement level slider (0-16)
/// - Two crystal slots with dropdowns
/// - Display of ring stats with enhancement bonuses
class RingSelector extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String?> onEquipChanged;
  final int enhance;
  final ValueChanged<int> onEnhChanged;
  final String? crystal1;
  final String? crystal2;
  final ValueChanged<String?> onCrystal1Changed;
  final ValueChanged<String?> onCrystal2Changed;

  const RingSelector({
    super.key,
    required this.selectedId,
    required this.onEquipChanged,
    required this.enhance,
    required this.onEnhChanged,
    required this.crystal1,
    required this.crystal2,
    required this.onCrystal1Changed,
    required this.onCrystal2Changed,
  });

  @override
  Widget build(BuildContext context) {
    final items = EquipmentData.itemsByType(EquipmentType.ring);
    final selectedItem = EquipmentData.findItem(selectedId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ring Dropdown
        _buildDropdown(
          icon: '💍',
          label: 'Select Ring',
          value: selectedId,
          items: items,
          onChanged: onEquipChanged,
        ),

        if (selectedItem != null) ...[
          const SizedBox(height: 16),

          // Enhancement Slider
          _buildEnhancementSlider(),

          const SizedBox(height: 16),

          // Stats Display
          _buildStatsDisplay(selectedItem),

          const SizedBox(height: 16),

          // Crystal Slots
          _buildCrystalSlots(),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String icon,
    required String label,
    required String? value,
    required List<EquipmentItem> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10A37F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF10A37F).withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButton<String>(
            value: value,
            hint: const Text(
              'Choose ring...',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: const Color(0xFF2A2A2A),
            style: const TextStyle(fontSize: 12, color: Colors.white),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('None'),
              ),
              ...items.map((item) {
                return DropdownMenuItem<String>(
                  value: item.id,
                  child: Text(item.name),
                );
              }),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancementSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '⬆️',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            const Text(
              'Enhancement: ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            Text(
              '+$enhance',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10A37F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF10A37F),
            inactiveTrackColor: const Color(0xFF10A37F).withValues(alpha: 0.2),
            thumbColor: const Color(0xFF10A37F),
            overlayColor: const Color(0xFF10A37F).withValues(alpha: 0.2),
            trackHeight: 3,
          ),
          child: Slider(
            value: enhance.toDouble(),
            min: 0,
            max: 16,
            divisions: 16,
            onChanged: (v) => onEnhChanged(v.toInt()),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsDisplay(EquipmentItem item) {
    final factor = 0.1 * enhance;

    int calcWithEnh(int base) {
      if (base == 0 || enhance == 0) return base;
      final extra = (base * factor).floor();
      return base + extra;
    }

    final stats = <MapEntry<String, int>>[];

    if (item.atk > 0) stats.add(MapEntry('ATK', calcWithEnh(item.atk)));
    if (item.matk > 0) stats.add(MapEntry('MATK', calcWithEnh(item.matk)));
    if (item.def > 0) stats.add(MapEntry('DEF', calcWithEnh(item.def)));
    if (item.mdef > 0) stats.add(MapEntry('MDEF', calcWithEnh(item.mdef)));
    if (item.str > 0) stats.add(MapEntry('STR', calcWithEnh(item.str)));
    if (item.dex > 0) stats.add(MapEntry('DEX', calcWithEnh(item.dex)));
    if (item.intStat > 0) stats.add(MapEntry('INT', calcWithEnh(item.intStat)));
    if (item.agi > 0) stats.add(MapEntry('AGI', calcWithEnh(item.agi)));
    if (item.vit > 0) stats.add(MapEntry('VIT', calcWithEnh(item.vit)));
    if (item.aspd > 0) stats.add(MapEntry('ASPD', calcWithEnh(item.aspd)));
    if (item.critRate > 0) {
      stats.add(MapEntry('Crit%', calcWithEnh(item.critRate)));
    }
    if (item.accuracy > 0) {
      stats.add(MapEntry('Accuracy', calcWithEnh(item.accuracy)));
    }
    if (item.stability > 0) {
      stats.add(MapEntry('Stability', calcWithEnh(item.stability)));
    }
    if (item.physicalPierce > 0) {
      stats.add(MapEntry('P.Pierce', calcWithEnh(item.physicalPierce)));
    }
    if (item.elementPierce > 0) {
      stats.add(MapEntry('E.Pierce', calcWithEnh(item.elementPierce)));
    }
    if (item.hp > 0) stats.add(MapEntry('HP', calcWithEnh(item.hp)));
    if (item.mp > 0) stats.add(MapEntry('MP', calcWithEnh(item.mp)));

    if (stats.isEmpty) {
      return const Text(
        'No stats',
        style: TextStyle(fontSize: 11, color: Colors.white38),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: stats.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF10A37F).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFF10A37F).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF10A37F),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCrystalSlots() {
    final crystals = EquipmentData.crystalBonuses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('💜', style: TextStyle(fontSize: 16)),
            SizedBox(width: 6),
            Text(
              'Crystal Slots',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10A37F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildCrystalDropdown('Slot 1', crystal1, onCrystal1Changed, crystals),
        const SizedBox(height: 8),
        _buildCrystalDropdown('Slot 2', crystal2, onCrystal2Changed, crystals),
      ],
    );
  }

  Widget _buildCrystalDropdown(
    String label,
    String? value,
    ValueChanged<String?> onChanged,
    List<CrystalBonus> crystals,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF10A37F).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white60),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              hint: const Text(
                'Empty',
                style: TextStyle(fontSize: 11, color: Colors.white38),
              ),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(fontSize: 11, color: Colors.white),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('None'),
                ),
                ...crystals.map((crystal) {
                  return DropdownMenuItem<String>(
                    value: crystal.id,
                    child: Text(crystal.id),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
