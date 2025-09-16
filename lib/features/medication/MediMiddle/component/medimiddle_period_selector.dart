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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: RadioListTile<int>(
            title: Text('특정일', style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
            value: 1,
            groupValue: selectedPeriod,
            onChanged: onChanged,
            activeColor: cs.primary,
            // 이게 체크/라디오 아이콘 색을 바꿔줌
          ),
        ),
        Expanded(
          child: RadioListTile<int>(
            title: Text('매일', style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
            value: 2,
            groupValue: selectedPeriod,
            onChanged: onChanged,
            activeColor: cs.primary,
          ),
        ),
      ],
    );
  }
}
