import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final displayTimes = (times.isEmpty)
        ? const <TimeOfDay>[
      TimeOfDay(hour: 8, minute: 0),   // 오전 08:00
      TimeOfDay(hour: 12, minute: 0),  // 오후 12:00
      TimeOfDay(hour: 18, minute: 0),  // 오후 18:00
    ]
        : times;

    return Column(
      children: List.generate(displayTimes.length, (i) {
        final t = displayTimes[i];
        // DateFormat('a hh:mm', 'ko_KR')를 쓰면 "오전 08:00" / "오후 12:00" / "오후 06:00" 같은 형식으로 표시됩니다.
        final formatted = DateFormat('a hh:mm', 'ko_KR')
            .format(DateTime(0, 0, 0, t.hour, t.minute));

        return ListTile(
          title: Text(formatted),
          trailing: const Icon(Icons.access_time),
          onTap: () async {
            // 사용자가 해당 행을 탭하면 showTimePicker를 띄워 주고, 선택된 시간이 있으면 onTimeChanged로 전달
            final picked = await showTimePicker(
              context: context,
              initialTime: t,
            );
            if (picked != null) {
              onTimeChanged(i, picked);
            }
          },
        );
      }),
    );
  }
}