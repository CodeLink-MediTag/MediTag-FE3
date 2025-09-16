// lib/features/medication/MediEnd/component/mediend_time_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 시간 리스트를 보여주고 탭하면 showTimePicker 띄워서 수정할 수 있게 함.
/// 각 행과 아이콘, 텍스트 색상은 테마를 따릅니다.
class TimeListPicker extends StatelessWidget {
  final List<TimeOfDay> times;
  final void Function(int index, TimeOfDay newTime) onTimeChanged;

  const TimeListPicker({
    Key? key,
    required this.times,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 빈 리스트면 기본 예시 시간을 보여줌
    final displayTimes = (times.isEmpty)
        ? const <TimeOfDay>[
      TimeOfDay(hour: 8, minute: 0),
      TimeOfDay(hour: 12, minute: 0),
      TimeOfDay(hour: 18, minute: 0),
    ]
        : times;

    return Column(
      children: List.generate(displayTimes.length, (i) {
        final t = displayTimes[i];
        // 유효한 DateTime으로 포맷 (month=1 day=1 등 유효값 사용)
        final formatted = DateFormat('a hh:mm', 'ko_KR').format(DateTime(2020, 1, 1, t.hour, t.minute));

        return Card(
          // 카드 배경도 테마에 맞춰줌 (cardColor 사용)
          color: theme.cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(formatted, style: theme.textTheme.bodyMedium),
            trailing: Icon(Icons.access_time, color: theme.iconTheme.color),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: t,
                builder: (ctx, child) {
                  // 다크테마 내부의 TimePicker도 theme으로 래핑해서 일관되게 보이게 함
                  return Theme(
                    data: Theme.of(ctx),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
              if (picked != null) onTimeChanged(i, picked);
            },
          ),
        );
      }),
    );
  }
}
