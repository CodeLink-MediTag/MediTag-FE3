import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/medimain_medicine.dart';
import '../model/medimain_alarm.dart';

class TimeButton extends StatelessWidget {
  final Medicine medicine;
  final Alarm alarm;
  final VoidCallback onToggleTaking;
  final VoidCallback onAskConfirm;

  const TimeButton({
    Key? key,
    required this.medicine,
    required this.alarm,
    required this.onToggleTaking,
    required this.onAskConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('a hh:mm', 'ko_KR').format(alarm.alarmTime);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: alarm.taking ? const Color(0xFFA3BCF1) : Colors.white,
          minimumSize: const Size(100, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: alarm.taking ? onToggleTaking : onAskConfirm,
        child: Text(
          alarm.taking ? '복용 완료!' : formatted,
          style: TextStyle(color: alarm.taking ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
