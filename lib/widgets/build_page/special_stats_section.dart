import 'package:flutter/material.dart';

class SpecialStatsSection extends StatelessWidget {
  const SpecialStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _sectionCard(
      title: "Special Stats",
      icon: Icons.bolt,
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

  Widget _statRow(String category, IconData? icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (category.isNotEmpty) ...[
            Icon(icon, color: Colors.cyanAccent, size: 20),
            const SizedBox(width: 8),
            Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
          ] else
            const SizedBox(width: 28),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 20),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
