import 'package:flutter/material.dart';

class CharacterStatsSection extends StatefulWidget {
  const CharacterStatsSection({super.key});

  @override
  State<CharacterStatsSection> createState() => _CharacterStatsSectionState();
}

class _CharacterStatsSectionState extends State<CharacterStatsSection> {
  int str = 1;
  int intStat = 1;
  int vit = 1;
  int agi = 1;
  int dex = 1;

  bool enabled = true;
  bool collapsed = false;

  int get totalPoints => str + intStat + vit + agi + dex;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E2A44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.cyanAccent),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Character Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: collapsed ? 'Expand' : 'Collapse',
                  icon: Icon(collapsed ? Icons.expand_more : Icons.expand_less,
                      color: Colors.white70),
                  onPressed: () => setState(() => collapsed = !collapsed),
                ),
                Tooltip(
                  message: enabled ? 'Disable section' : 'Enable section',
                  child: Switch(
                    value: enabled,
                    activeThumbColor: Colors.cyanAccent,
                    onChanged: (v) => setState(() => enabled = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (collapsed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3A55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Character Base Stats',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Total: $totalPoints',
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                        'STR:$str | INT:$intStat | VIT:$vit | AGI:$agi | DEX:$dex',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
                  ],
                ),
              )
            else
              Column(
                children: [
                  _statRow('STR', str, (v) => setState(() => str = v)),
                  _statRow('INT', intStat, (v) => setState(() => intStat = v)),
                  _statRow('VIT', vit, (v) => setState(() => vit = v)),
                  _statRow('AGI', agi, (v) => setState(() => agi = v)),
                  _statRow('DEX', dex, (v) => setState(() => dex = v)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 52,
              child:
                  Text(label, style: const TextStyle(color: Colors.white70))),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 510,
              divisions: 509,
              onChanged: enabled ? (v) => onChanged(v.toInt()) : null,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
              width: 48,
              child: Text(value.toString(),
                  style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
