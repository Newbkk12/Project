import 'package:flutter/material.dart';

class StatSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const StatSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text("$label: ${value.toInt()}")),
            SizedBox(
              width: 60,
              child: Text(
                value.toInt().toString(),
                textAlign: TextAlign.right,
              ),
            )
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toInt().toString(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
