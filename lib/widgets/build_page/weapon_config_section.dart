import 'package:flutter/material.dart';

class WeaponConfigSection extends StatelessWidget {
  const WeaponConfigSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _sectionCard(
      title: "Main Weapon",
      icon: Icons.gps_fixed,
      child: Column(
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

  Widget _enhancementSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Enhancement"),
        Row(
          children: [
            const Icon(Icons.add_circle, color: Colors.green),
            Expanded(child: Slider(value: 9, min: 0, max: 9, divisions: 9, onChanged: (v) {})),
            const Text("+S", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ],
    );
  }

  Widget _crystalSlot(String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      hint: const Text("Select or leave empty"),
      items: [],
      onChanged: (v) {},
    );
  }

  Widget _weaponPreviewBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF2A3A55), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Legendary Katana +S", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan)),
          Text("ATK: 245    STR +15    DEX +8", style: TextStyle(color: Colors.white70)),
          Text("ASPD: +500", style: TextStyle(color: Colors.yellow)),
          Text("Crystals: +20 ATK, +8% Critical Rate, +5 Physical Pierce", style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
