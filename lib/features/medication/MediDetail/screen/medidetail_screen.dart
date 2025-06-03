import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../component/medidetail_header.dart';
import '../component/medidetail_field_row.dart';
import '../component/medidetail_action_buttons.dart';
import '../../MediMain/model/medimain_medicine.dart';
import '../../MediEdit/screen/mediedit_screen.dart';
import 'package:medife/features/calendar/calendar.dart' hide Medicine, Alarm;

class MediDetailScreen extends StatefulWidget {
  final Medicine medicine;
  const MediDetailScreen({Key? key, required this.medicine}) : super(key: key);

  @override
  _MediDetailScreenState createState() => _MediDetailScreenState();
}

class _MediDetailScreenState extends State<MediDetailScreen> {
  late Medicine _currentMedicine;
  late DateTime _startDate;
  late int _duration;
  late List<String> _dosageTimes;
  late String _frequency;
  late TimeOfDay _alarmTime;

  @override
  void initState() {
    super.initState();
    _currentMedicine = widget.medicine;
    _applyMedicine(_currentMedicine);
  }

  void _applyMedicine(Medicine m) {
    final firstAlarm = m.alarms.first.alarmTime;
    _startDate = DateTime(firstAlarm.year, firstAlarm.month, firstAlarm.day);

    _duration = m.duration;

    _dosageTimes = m.alarms
        .map((a) => DateFormat('a hh:mm', 'ko_KR').format(a.alarmTime))
        .toList();

    _frequency = '${m.alarms.length}번';

    _alarmTime = TimeOfDay.fromDateTime(firstAlarm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상세페이지'),
        backgroundColor: const Color(0xFF547EE8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1) 헤더(이미지 + 이름 + 특징)
            MediDetailHeader(
              imageUrl: _currentMedicine.imageUrl ?? '',
              medicineName: _currentMedicine.medicineName,
              characteristic: _currentMedicine.characteristic,
            ),

            const SizedBox(height: 20),

            // 2) 필드 행들
            FieldRow(
              label: '복용 시작 날짜',
              value: DateFormat('yyyy-MM-dd').format(_startDate),
            ),
            FieldRow(label: '복용 기간', value: '$_duration일'),
            FieldRow(label: '복용 시간대', value: _dosageTimes.join(' / ')),
            FieldRow(label: '복용 주기', value: _frequency),

            const SizedBox(height: 24),

            // 3) 액션 버튼들
            MediDetailActions(
              medicine: _currentMedicine,
              onEdited: (updated) {
                setState(() {
                  _currentMedicine = updated;
                  _applyMedicine(_currentMedicine);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
