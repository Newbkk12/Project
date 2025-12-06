import 'package:flutter/material.dart';

class EquipmentCard extends StatelessWidget {
  final String title;
  final bool collapsed;
  final bool disabled;
  final Widget child;
  final VoidCallback onToggleCollapse;
  final VoidCallback onToggleEnable;

  const EquipmentCard({
    super.key,
    required this.title,
    required this.collapsed,
    required this.disabled,
    required this.child,
    required this.onToggleCollapse,
    required this.onToggleEnable,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: disabled ? Colors.grey.shade200 : null,
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: Icon(collapsed ? Icons.expand_more : Icons.expand_less), onPressed: onToggleCollapse),
              IconButton(icon: Icon(disabled ? Icons.visibility_off : Icons.visibility), onPressed: onToggleEnable),
            ]),
          ),
          if (!collapsed) Padding(padding: const EdgeInsets.all(8.0), child: child)
        ],
      ),
    );
  }
}
