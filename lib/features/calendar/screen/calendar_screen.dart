import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart';
import '../widgets/calendar_header.dart';
import '../widgets/calendar_medilist.dart';
import '../models/calendar_medi.dart';
import '../services/calendar_api.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Medicine> _medicines = [];
  Set<DateTime> _medDays = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAll();
  }

  Future<void> _loadAll() async {
    await CalendarApi.loadToken();
    final meds = await CalendarApi.fetchMedicinesForDate(_selectedDay!);
    final days = await CalendarApi.fetchMedicationDays();
    setState(() {
      _medicines = meds;
      _medDays = days;
    });
  }

  void _onDaySelected(DateTime selected, DateTime focused) async {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });
    final meds = await CalendarApi.fetchMedicinesForDate(selected);
    setState(() => _medicines = meds);
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: CustomAppBar(
        title: '복약기록 캘린더',
        height: 60, // 앱바 높이 명확히 고정
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              CalendarHeader(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay ?? DateTime.now(),
                events: _medDays,
                onDaySelected: _onDaySelected,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: CalendarMediList(
                  selectedDay: _selectedDay ?? DateTime.now(),
                  medicines: _medicines,
                  onAdded: _loadAll,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
