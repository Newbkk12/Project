import 'package:flutter/material.dart';
import '../../models/character_stats.dart';

class CharacterStatsCard extends StatefulWidget {
  final CharacterStats character;
  final VoidCallback onStatsChanged;

  const CharacterStatsCard({
    super.key,
    required this.character,
    required this.onStatsChanged,
  });

  @override
  State<CharacterStatsCard> createState() => _CharacterStatsCardState();
}

class _CharacterStatsCardState extends State<CharacterStatsCard> {
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
            value: widget.character.str,
            onChanged: (v) {
              setState(() {
                widget.character.str = v;
              });
            },
            onChangeEnd: () {
              widget.onStatsChanged();
            },
          ),
          _statSlider(
            label: 'INT',
            value: widget.character.intStat,
            onChanged: (v) {
              setState(() {
                widget.character.intStat = v;
              });
            },
            onChangeEnd: () {
              widget.onStatsChanged();
            },
          ),
          _statSlider(
            label: 'VIT',
            value: widget.character.vit,
            onChanged: (v) {
              setState(() {
                widget.character.vit = v;
              });
            },
            onChangeEnd: () {
              widget.onStatsChanged();
            },
          ),
          _statSlider(
            label: 'AGI',
            value: widget.character.agi,
            onChanged: (v) {
              setState(() {
                widget.character.agi = v;
              });
            },
            onChangeEnd: () {
              widget.onStatsChanged();
            },
          ),
          _statSlider(
            label: 'DEX',
            value: widget.character.dex,
            onChanged: (v) {
              setState(() {
                widget.character.dex = v;
              });
            },
            onChangeEnd: () {
              widget.onStatsChanged();
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
                value: widget.character.specialType.isEmpty
                    ? null
                    : widget.character.specialType,
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
                  setState(() {
                    widget.character.specialType = val ?? '';
                    if (widget.character.specialType.isEmpty) {
                      widget.character.specialValue = 1;
                    }
                  });
                  widget.onStatsChanged();
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (widget.character.specialType.isNotEmpty)
            _statSlider(
              label: 'Special Value',
              value: widget.character.specialValue,
              max: 255,
              onChanged: (v) {
                setState(() {
                  widget.character.specialValue = v;
                });
              },
              onChangeEnd: () {
                widget.onStatsChanged();
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
                  'Total Stats: ${widget.character.totalUsed}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Remaining Points: ${widget.character.remainingPoints}',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.character.remainingPoints == 0
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
    required VoidCallback onChangeEnd,
  }) {
    final TextEditingController textController = TextEditingController(
      text: value.toString(),
    );

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
              SizedBox(
                width: 70,
                child: TextField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF10A37F).withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF10A37F),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF10A37F),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF10A37F),
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (text) {
                    final newValue = int.tryParse(text);
                    if (newValue != null && newValue >= 1 && newValue <= max) {
                      onChanged(newValue);
                    }
                  },
                  onSubmitted: (text) {
                    final newValue = int.tryParse(text);
                    if (newValue != null && newValue >= 1 && newValue <= max) {
                      onChanged(newValue);
                      onChangeEnd();
                    } else {
                      textController.text = value.toString();
                    }
                  },
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
                    onChanged: (val) {
                      final intVal = val.toInt();
                      onChanged(intVal);
                      textController.text = intVal.toString();
                    },
                    onChangeEnd: (val) {
                      onChangeEnd();
                    },
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
