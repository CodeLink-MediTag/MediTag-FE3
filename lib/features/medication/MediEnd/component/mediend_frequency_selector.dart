import 'package:flutter/material.dart';

class FrequencySelector extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const FrequencySelector({Key? key, this.value, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [1, 2, 3, 4].map((count) {
        return Expanded(
          child: RadioListTile<int>(
            title: Text('$count회'),
            value: count,
            groupValue: value,
            onChanged: (v) => onChanged(v!),
          ),
        );
      }).toList(),
    );
  }
}