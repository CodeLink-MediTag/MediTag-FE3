// lib/features/calendar/widgets/calendar_header.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Set<DateTime> events;
  final void Function(DateTime, DateTime) onDaySelected;

  const CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 안전하게 TextStyle 준비 (널 대체)
    final TextStyle baseBody = theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    final TextStyle titleBase = theme.textTheme.titleLarge ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

    final Color textColor = baseBody.color ?? cs.onBackground;
    final Color iconColor = theme.iconTheme.color ?? cs.onBackground;
    final Color selectedBg = cs.primary;
    final Color selectedText = cs.onPrimary;
    final Color outsideText = textColor.withOpacity(0.35);
    final Color markerColor = cs.secondary;

    // 스타일 객체들
    final titleStyle = titleBase.copyWith(color: textColor, fontWeight: FontWeight.w600);
    final dayTextStyle = baseBody.copyWith(color: textColor);
    final outsideTextStyle = baseBody.copyWith(color: outsideText);
    final selectedTextStyle = baseBody.copyWith(color: selectedText, fontWeight: FontWeight.w600);

    return TableCalendar(
      locale: 'ko_KR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (d) => isSameDay(d, selectedDay),
      eventLoader: (d) => events.any((e) => isSameDay(e, d)) ? ['event'] : [],
      onDaySelected: (sel, foc) => onDaySelected(sel, foc),
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        leftChevronIcon: Icon(Icons.chevron_left, color: iconColor),
        rightChevronIcon: Icon(Icons.chevron_right, color: iconColor),
        titleTextStyle: titleStyle,
        headerPadding: const EdgeInsets.symmetric(vertical: 6),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: dayTextStyle,
        weekendStyle: dayTextStyle,
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: dayTextStyle,
        weekendTextStyle: dayTextStyle,
        outsideTextStyle: outsideTextStyle,
        todayDecoration: BoxDecoration(
          color: selectedBg.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: selectedBg,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: selectedTextStyle,
        markerDecoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
