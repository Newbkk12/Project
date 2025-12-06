import 'package:flutter/material.dart';
import '../../models/character_stats.dart';

class CharacterStatsCard extends StatelessWidget {
  final CharacterStats character;
  final VoidCallback onStatsChanged;

  const CharacterStatsCard({
    super.key,
    required this.character,
    required this.onStatsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF10A37F).withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statSlider(
            label: 'STR',
            value: character.str,
            onChanged: (v) {
              character.str = v;
              onStatsChanged();
            },
          ),
          _statSlider(
            label: 'INT',
            value: character.intStat,
            onChanged: (v) {
              character.intStat = v;
              onStatsChanged();
            },
          ),
          _statSlider(
            label: 'VIT',
            value: character.vit,
            onChanged: (v) {
              character.vit = v;
              onStatsChanged();
            },
          ),
          _statSlider(
            label: 'AGI',
            value: character.agi,
            onChanged: (v) {
              character.agi = v;
              onStatsChanged();
            },
          ),
          _statSlider(
            label: 'DEX',
            value: character.dex,
            onChanged: (v) {
              character.dex = v;
              onStatsChanged();
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Special Stat Type',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF10A37F).withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF343541),
                value: character.specialType.isEmpty
                    ? null
                    : character.specialType,
                hint: const Text(
                  '-- ไม่มี Special Stat --',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
                items: const [
                  DropdownMenuItem(value: 'CRT', child: Text('CRT (Critical)')),
                  DropdownMenuItem(value: 'LUK', child: Text('LUK (Luck)')),
                  DropdownMenuItem(
                    value: 'MTL',
                    child: Text('MTL (Mentality)'),
                  ),
                  DropdownMenuItem(
                    value: 'TEC',
                    child: Text('TEC (Technique)'),
                  ),
                ],
                onChanged: (val) {
                  character.specialType = val ?? '';
                  if (character.specialType.isEmpty) {
                    character.specialValue = 1;
                  }
                  onStatsChanged();
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (character.specialType.isNotEmpty)
            _statSlider(
              label: 'Special Value',
              value: character.specialValue,
              max: 255,
              onChanged: (v) {
                character.specialValue = v;
                onStatsChanged();
              },
            ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF10A37F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF10A37F).withValues(alpha: 0.3),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Stats: ${character.totalUsed}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Remaining Points: ${character.remainingPoints}',
                  style: TextStyle(
                    fontSize: 12,
                    color: character.remainingPoints == 0
                        ? Colors.redAccent
                        : Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statSlider({
    required String label,
    required int value,
    int max = 510,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10A37F), Color(0xFF0d8a6b)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    trackHeight: 4,
                    activeTrackColor: const Color(0xFF10A37F),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFF10A37F),
                    overlayColor:
                        const Color(0xFF10A37F).withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    min: 1,
                    max: max.toDouble(),
                    divisions: max - 1,
                    value: value.toDouble().clamp(1, max.toDouble()),
                    onChanged: (val) => onChanged(val.toInt()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
