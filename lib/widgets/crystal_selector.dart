import 'package:flutter/material.dart';
import '../models/crystal.dart';

class CrystalSelector extends StatelessWidget {
  final List<Crystal> crystals;
  final List<Crystal> selected;
  final ValueChanged<Crystal> onAdd;
  final ValueChanged<int> onRemove;

  const CrystalSelector({
    super.key,
    required this.crystals,
    required this.selected,
    required this.onAdd,
    required this.onRemove,
  });

  static Future<Crystal?> open(
    BuildContext context, [
    List<Crystal>? crystals,
  ]) async {
    final list = crystals ?? Crystal.sampleList;
    String filter = '';

    return showDialog<Crystal>(
      context: context,
      builder: (c) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filtered = list
                .where(
                  (cr) =>
                      filter.isEmpty ||
                      cr.name.toLowerCase().contains(filter.toLowerCase()),
                )
                .toList();
            return AlertDialog(
              title: const Text('Select Crystal'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => filter = v),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final cr = filtered[idx];
                          return ListTile(
                            title: Text(cr.name),
                            subtitle: Text(cr.type),
                            onTap: () => Navigator.of(context).pop(cr),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (int i = 0; i < 2; i++)
              OutlinedButton(
                onPressed: () async {
                  final res = await CrystalSelector.open(context, crystals);
                  if (res != null) onAdd(res);
                },
                child: Text(i < selected.length ? selected[i].name : 'Empty'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          children: [
            for (int i = 0; i < selected.length; i++)
              Chip(label: Text(selected[i].name), onDeleted: () => onRemove(i)),
          ],
        ),
      ],
    );
  }
}
