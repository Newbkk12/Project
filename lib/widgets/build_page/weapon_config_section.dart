import 'package:flutter/material.dart';
import '../../models/weapon.dart';
import '../../models/crystal.dart';

class WeaponConfigSection extends StatefulWidget {
  const WeaponConfigSection({super.key});

  @override
  State<WeaponConfigSection> createState() => _WeaponConfigSectionState();
}

class _WeaponConfigSectionState extends State<WeaponConfigSection> {
  // sample local weapons
  final List<Weapon> _weapons = [
    Weapon(id: 'w1', name: 'Wooden Sword', baseAtk: 10),
    Weapon(id: 'w2', name: 'Iron Blade', baseAtk: 55),
    Weapon(id: 'w3', name: 'Legendary Katana', baseAtk: 245),
  ];

  Weapon? selectedWeapon;
  List<Crystal> selectedCrystals = [];
  bool collapsed = false;

  @override
  Widget build(BuildContext context) {
    return _sectionCard(
      title: 'Main Weapon',
      icon: Icons.gps_fixed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(selectedWeapon?.name ?? 'No weapon selected',
                style: const TextStyle(color: Colors.white)),
            subtitle: selectedWeapon != null
                ? Text('WATK ${selectedWeapon!.watk}',
                    style: const TextStyle(color: Colors.white70))
                : null,
            trailing: ElevatedButton.icon(
              onPressed: () => _openWeaponDialog(context),
              icon: const Icon(Icons.search),
              label: const Text('Select'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Refine:', style: TextStyle(color: Colors.white70)),
              Expanded(
                child: Slider(
                  value: (selectedWeapon?.refine ?? 0).toDouble(),
                  min: 0,
                  max: 15,
                  divisions: 15,
                  onChanged: (v) {
                    if (selectedWeapon != null)
                      setState(() => selectedWeapon!.refine = v.toInt());
                  },
                ),
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: TextEditingController(
                      text: (selectedWeapon?.watk ?? 0).toString()),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8)),
                  onSubmitted: (val) {
                    if (selectedWeapon != null)
                      setState(() => selectedWeapon!.watk =
                          int.tryParse(val) ?? selectedWeapon!.watk);
                  },
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  if (selectedWeapon != null) selectedWeapon!.watk++;
                }),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
              IconButton(
                onPressed: () => setState(() {
                  if (selectedWeapon != null) selectedWeapon!.watk--;
                }),
                icon: const Icon(Icons.remove, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCrystalSelector(),
        ],
      ),
    );
  }

  Widget _sectionCard(
      {required String title, required IconData icon, required Widget child}) {
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
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(collapsed ? Icons.expand_more : Icons.expand_less,
                      color: Colors.white70),
                  onPressed: () => setState(() => collapsed = !collapsed),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (collapsed)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFF2A3A55),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedWeapon?.name ?? 'No weapon',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                        selectedWeapon != null
                            ? 'ATK: ${selectedWeapon!.watk}'
                            : '',
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              )
            else
              child,
          ],
        ),
      ),
    );
  }

  void _openWeaponDialog(BuildContext context) async {
    String filter = '';
    final Weapon? w = await showDialog<Weapon>(
      context: context,
      builder: (c) {
        return StatefulBuilder(builder: (c2, setStateDialog) {
          final list = _weapons
              .where((w) =>
                  filter.isEmpty ||
                  w.name.toLowerCase().contains(filter.toLowerCase()))
              .toList();
          return AlertDialog(
            title: const Text('Select Weapon'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => setStateDialog(() => filter = v),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search), hintText: 'Search'),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        final ww = list[i];
                        return ListTile(
                          title: Text(ww.name),
                          subtitle: Text('Base ATK ${ww.baseAtk}'),
                          onTap: () => Navigator.of(context).pop(ww),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );

    if (w != null) setState(() => selectedWeapon = w);
  }

  Widget _buildCrystalSelector() {
    final crystals = Crystal.sampleList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: crystals.map((c) {
            final isSelected = selectedCrystals.any((s) => s.id == c.id);
            return ChoiceChip(
              label: Text(c.name),
              selected: isSelected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    if (!isSelected && selectedCrystals.length < 2)
                      selectedCrystals.add(c);
                  } else {
                    selectedCrystals.removeWhere((s) => s.id == c.id);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: selectedCrystals.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                  label: Text(e.value.name),
                  onDeleted: () =>
                      setState(() => selectedCrystals.removeAt(e.key))),
            );
          }).toList(),
        ),
      ],
    );
  }
}
