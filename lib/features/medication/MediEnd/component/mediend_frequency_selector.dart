// lib/features/medication/MediEnd/component/mediend_frequency_selector.dart
import 'package:flutter/material.dart';

/// 1~4회 중 하나를 선택하는 라디오 UI
/// 라디오의 활성 색상, 텍스트 색상 등은 테마에서 가져옵니다.
class FrequencySelector extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const FrequencySelector({Key? key, this.value, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [1, 2, 3, 4].map((count) {
        final isSelected = (value == count);
        return Expanded(
          child: RadioListTile<int>(
            title: Text(
              '$count회',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? cs.primary : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            value: count,
            groupValue: value,
            onChanged: (v) => onChanged(v ?? count),
            activeColor: cs.primary, // 라디오의 활성 컬러
            contentPadding: EdgeInsets.zero,
          ),
        );
      }).toList(),
    );
  }
}
