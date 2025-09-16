import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EatCard extends StatelessWidget {
  final String pillName;
  final List<String> times;
  final Map<String, bool> takenMap;
  final void Function(String time) onTaken;
  final bool prescribed; // ✅

  const EatCard({
    super.key,
    required this.pillName,
    required this.times,
    required this.takenMap,
    required this.onTaken,
    required this.prescribed,
  });

  // 버튼 색은 테마 기반(primary)과 완료 상태 색(secondaryContainer 또는 fallback) 사용
  Color _getDefaultButtonColor(ColorScheme cs) {
    return cs.primary;
  }

  Color _getTakenColor(ColorScheme cs) {
    // 다크/라이트에서 대비 좋은 색을 고르도록 우선순위:
    // 1) secondaryContainer (있으면)
    // 2) fallback pink (기존 디자인 유지)
    return cs.secondaryContainer ?? const Color(0xFFF4B7E8);
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final titleStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) ??
        TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: theme.textTheme.bodyLarge?.fontFamily);

    final buttonTextStyle = theme.textTheme.bodyLarge?.copyWith(color: cs.onPrimary) ??
        TextStyle(color: cs.onPrimary, fontSize: 16);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 4,
      color: theme.cardColor, // 테마 카드 색 사용
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목(폰트는 theme.textTheme 에서 가져와서 글로벌 fontFamily 적용)
            Text(
              pillName,
              style: titleStyle,
            ),
            const SizedBox(height: 12),
            // 시간 버튼들
            ...times.map((time) {
              final taken = takenMap[time] == true;
              final bg = taken ? _getTakenColor(cs) : _getDefaultButtonColor(cs);
              final fg = taken ? cs.onSecondaryContainer ?? Colors.white : cs.onPrimary;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: taken ? null : () => onTaken(time),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bg,
                    foregroundColor: fg,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    getButtonText(time),
                    style: theme.textTheme.bodyLarge?.copyWith(color: fg, fontSize: 16),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
