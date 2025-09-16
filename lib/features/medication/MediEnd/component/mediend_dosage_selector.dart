// lib/features/medication/MediEnd/component/mediend_dosage_selector.dart
import 'package:flutter/material.dart';

/// 여러 복용 라벨(예: 아침/점심/저녁)을 토글할 수 있는 UI
/// 필터 칩을 사용하며, 칩의 색/텍스트는 현재 테마에 따라 변경됩니다.
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Wrap(
      spacing: 8,
      children: options.map((time) {
        final isSelected = selected.contains(time);

        // 선택/미선택 상태에 따라 칩 배경과 라벨 색상 결정
        final chipBg = isSelected ? cs.primary : theme.cardColor;
        final labelColor = isSelected ? cs.onPrimary : theme.textTheme.bodyMedium?.color;

        return FilterChip(
          label: Text(time, style: TextStyle(color: labelColor)),
          selected: isSelected,
          onSelected: (sel) {
            final newList = List<String>.from(selected);
            if (sel) {
              if (!newList.contains(time)) newList.add(time);
            } else {
              newList.remove(time);
            }
            onChanged(newList);
          },
          // 테마 기반 색 적용
          selectedColor: chipBg,
          backgroundColor: theme.cardColor,
          checkmarkColor: cs.onPrimary,
          side: BorderSide(color: isSelected ? cs.primary : Colors.transparent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }
}
