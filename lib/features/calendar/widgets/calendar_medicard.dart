import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_medi.dart';

class CalendarMedicard extends StatelessWidget {
  final Medicine medicine;
  const CalendarMedicard({Key? key, required this.medicine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...medicine.alarms.map((a) {
              final time = DateFormat('HH:mm').format(a.time);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(time),
                  Text(
                    a.taken ? '복용' : '미복용',
                    style: TextStyle(color: a.taken ? Colors.green : Colors.grey),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}