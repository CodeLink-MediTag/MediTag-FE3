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
    return TableCalendar(
      locale: 'ko_KR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (d) => isSameDay(d, selectedDay),
      eventLoader: (d) => events.any((e) => isSameDay(e, d)) ? ['x'] : [],
      onDaySelected: onDaySelected,
      headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(color: Colors.pink[200], shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
        markerDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
      ),
    );
  }
}