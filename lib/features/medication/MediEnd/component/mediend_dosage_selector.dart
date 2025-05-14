import 'package:flutter/material.dart';

class DosageSelector extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const DosageSelector({
    Key? key,
    required this.options,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((time) {
        return FilterChip(
          label: Text(time),
          selected: selected.contains(time),
          onSelected: (sel) {
            final newList = List<String>.from(selected);
            if (sel) newList.add(time);
            else newList.remove(time);
            onChanged(newList);
          },
        );
      }).toList(),
    );
  }
}