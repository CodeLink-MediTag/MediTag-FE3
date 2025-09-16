import 'package:flutter/material.dart';

class MediStartRecordingDropdown extends StatelessWidget {
  final List<String> recordings;
  final String? selectedRecording;
  final ValueChanged<String?> onChanged;

  const MediStartRecordingDropdown({
    Key? key,
    required this.recordings,
    required this.selectedRecording,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목은 테마의 텍스트 스타일 사용
        Text(
          '녹음하신 주의사항이 있다면 선택해주세요.',
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedRecording,
          decoration: InputDecoration(
            filled: true,
            // 배경은 카드 색(라이트/다크 안전)
            fillColor: theme.cardColor,
            // 테두리는 theme.dividerColor 사용
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          hint: Text('녹음 1', style: theme.textTheme.bodyMedium),
          dropdownColor: theme.cardColor, // 드롭다운 패널 배경도 테마에 맞춤
          style: theme.textTheme.bodyLarge, // 드롭다운 텍스트 스타일
          onChanged: onChanged,
          items: recordings.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: theme.textTheme.bodyLarge),
            );
          }).toList(),
        ),
      ],
    );
  }
}
