import 'package:flutter/material.dart';

class CharacterStatsSection extends StatelessWidget {
  const CharacterStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _sectionCard(
      title: "Character Stats",
      icon: Icons.person,
      child: Column(
        children: [],
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Widget child}) {
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
                Icon(icon, color: Colors.cyanAccent),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _statSlider(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(label, style: TextStyle(color: color))),
          Expanded(
            child: Slider(value: 1, min: 1, max: 255, divisions: 254, onChanged: (v) {}),
          ),
          const SizedBox(width: 40, child: Text("1", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _specialStatDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: "Special Stat Type"),
      hint: const Text("— Select Special Stat —"),
      items: ["Critical Rate", "ASPD", "Physical Pierce"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) {},
    );
  }

  Widget _specialStatSlider() {
    return Row(
      children: const [
        Text("Special Stat Value"),
        Expanded(child: Slider(value: 1, min: 1, max: 50, onChanged: null)),
        SizedBox(width: 40, child: Text("1")),
      ],
    );
  }

  Widget _baseStatsBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF2A3A55), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: const [
          Text("Character Base Stats", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Total Stats: 5        Remaining Points: 780"),
          SizedBox(height: 4),
          Text("STR:1 | INT:1 | VIT:1 | AGI:1 | DEX:1", style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
