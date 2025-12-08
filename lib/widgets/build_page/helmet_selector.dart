import 'package:flutter/material.dart';
import '../../models/equipment_data.dart';
import '../../providers/theme_provider.dart';

/// HelmetSelector - Widget for selecting and configuring helmet
///
/// This widget provides:
/// - Dropdown for selecting helmet from available items
/// - Enhancement level slider (0-16)
/// - Two crystal slots with dropdowns
/// - Display of helmet stats with enhancement bonuses
class HelmetSelector extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String?> onEquipChanged;
  final int enhance;
  final ValueChanged<int> onEnhChanged;
  final String? crystal1;
  final String? crystal2;
  final ValueChanged<String?> onCrystal1Changed;
  final ValueChanged<String?> onCrystal2Changed;

  const HelmetSelector({
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
    final selectedItem = EquipmentData.findItem(selectedId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Helmet Dropdown
        _buildDropdown(
          icon: '🎩',
          label: 'Select Helmet',
          value: selectedId,
          onChanged: onEquipChanged,
          context: context,
        ),

        if (selectedItem != null) ...[
          const SizedBox(height: 16),

          // Enhancement Slider
          _buildEnhancementSlider(context),

          const SizedBox(height: 16),

          // Stats Display
          _buildStatsDisplay(selectedItem, context),

          const SizedBox(height: 16),

          // Crystal Slots
          _buildCrystalSlots(context),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String icon,
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final items = EquipmentData.itemsByType(EquipmentType.helmet);
    final selectedItem = items.where((item) => item.id == value).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showItemPicker(context, items, value, onChanged, label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItem?.name ?? 'Choose helmet...',
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedItem != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showItemPicker(
    BuildContext context,
    List<EquipmentItem> items,
    String? currentValue,
    ValueChanged<String?> onChanged,
    String label,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ItemPickerDialog(
        items: items,
        currentValue: currentValue,
        onChanged: onChanged,
        label: label,
      ),
    );
  }

  Widget _buildEnhancementSlider(BuildContext context) {
    final theme = Theme.of(context);

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
            Text(
              'Enhancement: ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '+$enhance',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: theme.primaryColor,
            inactiveTrackColor: theme.primaryColor.withValues(alpha: 0.2),
            thumbColor: theme.primaryColor,
            overlayColor: theme.primaryColor.withValues(alpha: 0.2),
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

  Widget _buildStatsDisplay(EquipmentItem item, BuildContext context) {
    final theme = Theme.of(context);
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
      return Text(
        'No stats',
        style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: stats.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: TextStyle(
              fontSize: 10,
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCrystalSlots(BuildContext context) {
    final theme = Theme.of(context);
    final crystals = EquipmentData.crystalBonuses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('💛', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              'Crystal Slots',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildCrystalDropdown(
            'Slot 1', crystal1, onCrystal1Changed, crystals, context),
        const SizedBox(height: 8),
        _buildCrystalDropdown(
            'Slot 2', crystal2, onCrystal2Changed, crystals, context),
      ],
    );
  }

  Widget _buildCrystalDropdown(
    String label,
    String? value,
    ValueChanged<String?> onChanged,
    List<CrystalBonus> crystals,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'Empty',
                style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              ),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: customColors?.cardBackground ?? theme.cardColor,
              style:
                  TextStyle(fontSize: 11, color: theme.colorScheme.onSurface),
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

class _ItemPickerDialog extends StatefulWidget {
  final List<EquipmentItem> items;
  final String? currentValue;
  final ValueChanged<String?> onChanged;
  final String label;

  const _ItemPickerDialog({
    required this.items,
    required this.currentValue,
    required this.onChanged,
    required this.label,
  });

  @override
  State<_ItemPickerDialog> createState() => _ItemPickerDialogState();
}

class _ItemPickerDialogState extends State<_ItemPickerDialog> {
  late List<EquipmentItem> filteredItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        filteredItems = widget.items
            .where(
                (item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return Dialog(
      backgroundColor: customColors?.cardBackground ?? theme.cardColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search field
            TextField(
              controller: searchController,
              onChanged: _filterItems,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อไอเทม...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.primaryColor,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Items list
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: Text(
                        'None',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                      selected: widget.currentValue == null,
                      selectedTileColor:
                          theme.primaryColor.withValues(alpha: 0.2),
                      onTap: () {
                        widget.onChanged(null);
                        Navigator.pop(context);
                      },
                    );
                  }

                  final item = filteredItems[index - 1];
                  return ListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                    selected: widget.currentValue == item.id,
                    selectedTileColor:
                        theme.primaryColor.withValues(alpha: 0.2),
                    onTap: () {
                      widget.onChanged(item.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
