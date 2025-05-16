import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 달력 모듈의 Medicine/Alarm 숨기기
import 'package:medife/features/calendar/calendar.dart' hide Medicine, Alarm;

// 내 모델만 올바른 경로로 불러오기
import '../MediMain/model/medimain_medicine.dart';
import '../MediMain/model/medimain_alarm.dart';

class MediEdit extends StatefulWidget {
  final Medicine medicine;
  const MediEdit({Key? key, required this.medicine}) : super(key: key);

  @override
  _MediEditState createState() => _MediEditState();
}

class _MediEditState extends State<MediEdit> {
  late TextEditingController _nameCtrl;
  late TextEditingController _durationCtrl;
  late DateTime _startDate;
  late List<TimeOfDay> _alarmTimes;
  late bool _prescribed;
  final List<String> _dosageOptions = ['아침', '점심', '저녁'];
  late List<String> _selectedDosage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.medicine.medicineName);
    _durationCtrl =
        TextEditingController(text: widget.medicine.alarms.length.toString());
    _prescribed = widget.medicine.prescribed;

    // 시작 날짜
    final first = widget.medicine.alarms.first.alarmTime;
    _startDate = DateTime(first.year, first.month, first.day);

    // 알람 시간 리스트
    _alarmTimes = widget.medicine.alarms
        .map((a) => TimeOfDay.fromDateTime(a.alarmTime))
        .toList();

    // 자동 분류 복용 시간대
    _selectedDosage = _alarmTimes.map((tod) {
      if (tod.hour < 12) return '아침';
      if (tod.hour < 18) return '점심';
      return '저녁';
    }).toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _pickTime(int idx) async {
    final t = await showTimePicker(
      context: context,
      initialTime: _alarmTimes[idx],
    );
    if (t != null) setState(() => _alarmTimes[idx] = t);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final body = {
      'medicineName': widget.medicine.medicineName,
      'newName': _nameCtrl.text,
      'startDate': DateFormat('yyyy-MM-dd').format(_startDate),
      'duration': int.parse(_durationCtrl.text),
      'prescribed': _prescribed,
      'dosageTimes': _prescribed ? _selectedDosage : [],
      'alarmTimes': _alarmTimes.map((tod) {
        return DateFormat('HH:mm:ss').format(DateTime(
            _startDate.year, _startDate.month, _startDate.day, tod.hour, tod.minute));
      }).toList(),
    };

    final res = await http.put(
      Uri.parse('http://localhost:8080/api/medicines'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      final updated = Medicine(
        medicineName: _nameCtrl.text,
        characteristic: widget.medicine.characteristic,
        imageUrl: widget.medicine.imageUrl,
        prescribed: _prescribed,
        alarms: _alarmTimes.map((tod) {
          return Alarm(
            alarmTime: DateTime(
                _startDate.year, _startDate.month, _startDate.day, tod.hour, tod.minute),
            taking: false,
          );
        }).toList(),
        isFavorite: widget.medicine.isFavorite,
      );
      Navigator.pop(context, updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            Text('정보 수정 실패: ${res.statusCode}\n${res.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정보 수정'),
        backgroundColor: const Color(0xFF547EE8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: '약 이름'),
          ),
          const SizedBox(height: 24),
          ListTile(
            title: Text(
                '복용 시작 날짜: ${DateFormat('yyyy-MM-dd').format(_startDate)}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _durationCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '복용 기간 (일)'),
          ),
          const SizedBox(height: 24),
          if (_prescribed) ...[
            const Text('복용 시간대',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _dosageOptions.map((opt) {
                return ChoiceChip(
                  label: Text(opt),
                  selected: _selectedDosage.contains(opt),
                  onSelected: (sel) {
                    setState(() {
                      if (sel)
                        _selectedDosage.add(opt);
                      else
                        _selectedDosage.remove(opt);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          const Text('알림 시간',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(_alarmTimes.length, (i) {
            return ListTile(
              title: Text(_alarmTimes[i].format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(i),
            );
          }),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF547EE8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('저장',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}
