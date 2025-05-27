import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EatCard extends StatelessWidget {
  final String pillName;
  final List<String> times;
  final Map<String, bool> takenMap;
  final void Function(String time) onTaken;
  final bool prescribed; // ✅ 추가

  const EatCard({
    super.key,
    required this.pillName,
    required this.times,
    required this.takenMap,
    required this.onTaken,
    required this.prescribed, // ✅ 추가
  });

  Color getButtonColor(String time) {
    return takenMap[time] == true ? const Color(0xFFF4B7E8) : const Color(0xFF547EE8);
  }

  String formatToHourMinute(String isoDateTime) {
    try {
      final dateTime = DateTime.parse(isoDateTime);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoDateTime; // 파싱 실패 시 원본 그대로 반환
    }
  }

  String getButtonText(String time) {
    final displayTime = prescribed ? time : formatToHourMinute(time);
    return takenMap[time] == true ? '$displayTime 복용 완료!' : displayTime;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pillName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...times.map((time) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: takenMap[time] == true ? null : () => onTaken(time),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getButtonColor(time),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    getButtonText(time),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            }).toList()
          ],
        ),
      ),
    );
  }
}
