import 'package:flutter/material.dart';
import '../models/calendar_medi.dart';
import 'calendar_medicard.dart';
import '../../medication/MediStart/screen/medistart_screen.dart';

class CalendarMediList extends StatelessWidget {
  final DateTime selectedDay;
  final List<Medicine> medicines;
  final Future<void> Function() onAdded;

  const CalendarMediList({
    Key? key,
    required this.selectedDay,
    required this.medicines,
    required this.onAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('선택 날짜에 복용 약이 없어요', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push<bool>(
                  MaterialPageRoute(
                    builder: (_) => MediStartScreen(initialDate: selectedDay),
                  ),
                )
                    .then((res) {
                  if (res == true) onAdded();
                });
              },
              child: const Text('복용중인 약 추가'),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: medicines.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) => CalendarMedicard(medicine: medicines[i]),
      ),
    );
  }
}