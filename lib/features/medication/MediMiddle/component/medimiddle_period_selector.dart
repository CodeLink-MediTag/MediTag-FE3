import 'package:flutter/material.dart';

class MediMiddlePeriodSelector extends StatelessWidget {
  final int? selectedPeriod;
  final ValueChanged<int?> onChanged;

  const MediMiddlePeriodSelector({
    Key? key,
    required this.selectedPeriod,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<int>(
            title: const Text('특정일', style: TextStyle(fontSize: 16)),
            value: 1,
            groupValue: selectedPeriod,
            onChanged: onChanged,
          ),
        ),
        Expanded(
          child: RadioListTile<int>(
            title: const Text('매일', style: TextStyle(fontSize: 16)),
            value: 2,
            groupValue: selectedPeriod,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}