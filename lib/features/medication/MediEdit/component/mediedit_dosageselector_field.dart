import 'package:flutter/material.dart';

/// ChoiceChip을 이용해서 “아침/점심/저녁” 중에서 처방약 시간대를 사용자가 선택하게끔 해줌

class DosageSelectorField extends StatelessWidget {
  final List<String> options;     // ['아침', '점심', '저녁']
  final List<String> selected;    // 현재 선택된 값(문자열 리스트)
  final ValueChanged<List<String>> onChanged;

  const DosageSelectorField({
    Key? key,
    required this.options,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('복용 시간대', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            return ChoiceChip(
              label: Text(opt),
              selected: selected.contains(opt),
              onSelected: (isOn) {
                List<String> newList = List.from(selected);
                if (isOn) {
                  newList.add(opt);
                } else {
                  newList.remove(opt);
                }
                onChanged(newList);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
