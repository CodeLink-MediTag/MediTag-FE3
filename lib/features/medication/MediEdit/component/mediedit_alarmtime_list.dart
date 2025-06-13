import 'package:flutter/material.dart';

/// “알림 시간 리스트”를 렌더링 times: 현재 선택된 TimeOfDay 리스트 onTimeChanged: (인덱스, 새로운 시간) 콜백

class AlarmTimeListField extends StatelessWidget {
  final List<TimeOfDay> times;
  /// (idx, _unused) 대신에 idx만 전달
  final void Function(int idx) onTapAt;

  const AlarmTimeListField({
    Key? key,
    required this.times,
    required this.onTapAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('알림 시간', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Column(
          children: List.generate(times.length, (i) {
            final t = times[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.format(context), style: const TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.access_time),
                // **여기서는** 다이얼로그를 띄우지 않고
                // 인덱스만 부모에게 알려줍니다.
                onTap: () => onTapAt(i),
              ),
            );
          }),
        ),
      ],
    );
  }
}
