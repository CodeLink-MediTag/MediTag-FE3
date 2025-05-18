// lib/features/medication/MediEnd/component/mediend_time_list.dart

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
    return Column(
      children: List.generate(times.length, (i) {
        final t = times[i];
        return ListTile(
          title: Text(DateFormat('a hh:mm', 'ko_KR')
              .format(DateTime(0, 0, 0, t.hour, t.minute))),
          trailing: const Icon(Icons.access_time),
          onTap: () async {
            final picked =
            await showTimePicker(context: context, initialTime: t);
            if (picked != null) onTimeChanged(i, picked);
          },
        );
      }),
    );
  }
}


/*

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeListPicker extends StatelessWidget {
  final List<TimeOfDay> times;
  final ValueChanged<MapEntry<int, TimeOfDay>> onTimeChanged;

  const TimeListPicker({Key? key, required this.times, required this.onTimeChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: times.asMap().entries.map((entry) {
        final idx = entry.key;
        final t = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: t);
              if (picked != null) onTimeChanged(MapEntry(idx, picked));
            },
            child: Container(
              height: 53,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('a hh:mm', 'ko_KR').format(
                      DateTime(0,0,0,t.hour,t.minute)
                  )),
                  const Icon(Icons.access_time, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

 */