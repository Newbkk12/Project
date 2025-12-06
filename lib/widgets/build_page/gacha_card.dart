import 'package:flutter/material.dart';
import '../../models/equipment_data.dart';

class GachaCard extends StatelessWidget {
  final String? gacha1Stat1;
  final String? gacha1Stat2;
  final String? gacha1Stat3;
  final String? gacha2Stat1;
  final String? gacha2Stat2;
  final String? gacha2Stat3;
  final String? gacha3Stat1;
  final String? gacha3Stat2;
  final String? gacha3Stat3;
  final ValueChanged<String?> onGacha1Stat1Changed;
  final ValueChanged<String?> onGacha1Stat2Changed;
  final ValueChanged<String?> onGacha1Stat3Changed;
  final ValueChanged<String?> onGacha2Stat1Changed;
  final ValueChanged<String?> onGacha2Stat2Changed;
  final ValueChanged<String?> onGacha2Stat3Changed;
  final ValueChanged<String?> onGacha3Stat1Changed;
  final ValueChanged<String?> onGacha3Stat2Changed;
  final ValueChanged<String?> onGacha3Stat3Changed;

  const GachaCard({
    super.key,
    required this.gacha1Stat1,
    required this.gacha1Stat2,
    required this.gacha1Stat3,
    required this.gacha2Stat1,
    required this.gacha2Stat2,
    required this.gacha2Stat3,
    required this.gacha3Stat1,
    required this.gacha3Stat2,
    required this.gacha3Stat3,
    required this.onGacha1Stat1Changed,
    required this.onGacha1Stat2Changed,
    required this.onGacha1Stat3Changed,
    required this.onGacha2Stat1Changed,
    required this.onGacha2Stat2Changed,
    required this.onGacha2Stat3Changed,
    required this.onGacha3Stat1Changed,
    required this.onGacha3Stat2Changed,
    required this.onGacha3Stat3Changed,
  });

  @override
  Widget build(BuildContext context) {
    final gachaItems = <DropdownMenuItem<String>>[];
    gachaItems.add(
      const DropdownMenuItem(
        value: '',
        child: Text('-- Select Stat --', style: TextStyle(fontSize: 11)),
      ),
    );
    for (int i = 0; i < EquipmentData.gachaBonuses.length; i++) {
      final g = EquipmentData.gachaBonuses[i];
      gachaItems.add(
        DropdownMenuItem(
          value: g.id,
          child: Text(g.display, style: const TextStyle(fontSize: 11)),
        ),
      );
    }

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
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _gachaSlot(
                        'Gacha Slot 1',
                        gacha1Stat1,
                        gacha1Stat2,
                        gacha1Stat3,
                        onGacha1Stat1Changed,
                        onGacha1Stat2Changed,
                        onGacha1Stat3Changed,
                        _buildSummary(gacha1Stat1, gacha1Stat2, gacha1Stat3),
                        gachaItems,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _gachaSlot(
                        'Gacha Slot 2',
                        gacha2Stat1,
                        gacha2Stat2,
                        gacha2Stat3,
                        onGacha2Stat1Changed,
                        onGacha2Stat2Changed,
                        onGacha2Stat3Changed,
                        _buildSummary(gacha2Stat1, gacha2Stat2, gacha2Stat3),
                        gachaItems,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _gachaSlot(
                        'Gacha Slot 3',
                        gacha3Stat1,
                        gacha3Stat2,
                        gacha3Stat3,
                        onGacha3Stat1Changed,
                        onGacha3Stat2Changed,
                        onGacha3Stat3Changed,
                        _buildSummary(gacha3Stat1, gacha3Stat2, gacha3Stat3),
                        gachaItems,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _gachaSlot(
                    'Gacha Slot 1',
                    gacha1Stat1,
                    gacha1Stat2,
                    gacha1Stat3,
                    onGacha1Stat1Changed,
                    onGacha1Stat2Changed,
                    onGacha1Stat3Changed,
                    _buildSummary(gacha1Stat1, gacha1Stat2, gacha1Stat3),
                    gachaItems,
                  ),
                  const SizedBox(height: 12),
                  _gachaSlot(
                    'Gacha Slot 2',
                    gacha2Stat1,
                    gacha2Stat2,
                    gacha2Stat3,
                    onGacha2Stat1Changed,
                    onGacha2Stat2Changed,
                    onGacha2Stat3Changed,
                    _buildSummary(gacha2Stat1, gacha2Stat2, gacha2Stat3),
                    gachaItems,
                  ),
                  const SizedBox(height: 12),
                  _gachaSlot(
                    'Gacha Slot 3',
                    gacha3Stat1,
                    gacha3Stat2,
                    gacha3Stat3,
                    onGacha3Stat1Changed,
                    onGacha3Stat2Changed,
                    onGacha3Stat3Changed,
                    _buildSummary(gacha3Stat1, gacha3Stat2, gacha3Stat3),
                    gachaItems,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _gachaSlot(
    String title,
    String? s1,
    String? s2,
    String? s3,
    ValueChanged<String?> onS1,
    ValueChanged<String?> onS2,
    ValueChanged<String?> onS3,
    List<String> summaryTexts,
    List<DropdownMenuItem<String>> gachaItems,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF10A37F).withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎲'),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10A37F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GachaRow(
            label: 'Stat 1:',
            value: s1,
            items: gachaItems,
            onChanged: onS1,
          ),
          const SizedBox(height: 8),
          GachaRow(
            label: 'Stat 2:',
            value: s2,
            items: gachaItems,
            onChanged: onS2,
          ),
          const SizedBox(height: 8),
          GachaRow(
            label: 'Stat 3:',
            value: s3,
            items: gachaItems,
            onChanged: onS3,
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF10A37F).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF10A37F).withValues(alpha: 0.3),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Stats:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10A37F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summaryTexts.isEmpty
                      ? 'No stats selected'
                      : summaryTexts.join(' • '),
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildSummary(String? a, String? b, String? c) {
    final result = <String>[];
    void add(String? id) {
      if (id == null || id.isEmpty) return;
      final g = EquipmentData.findGacha(id);
      if (g == null) return;
      result.add(g.display);
    }

    add(a);
    add(b);
    add(c);
    return result;
  }
}

class GachaRow extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const GachaRow({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: const Color(0xFF10A37F).withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF343541),
              value: value ?? '',
              items: items,
              onChanged: (val) {
                if (val == '') {
                  onChanged(null);
                } else {
                  onChanged(val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
