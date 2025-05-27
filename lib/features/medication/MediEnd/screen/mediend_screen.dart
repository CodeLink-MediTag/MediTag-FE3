import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:medife/ip/ip_address.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../ip/ip_address.dart';
import '../model/mediend_selection_data.dart';
import '../component/mediend_app_bar.dart';
import '../component/mediend_dosage_selector.dart';
import '../component/mediend_frequency_selector.dart';
import '../component/mediend_time_list.dart';
import '../component/mediend_submit_button.dart';

/// TimeOfDay 에 따라 '아침'/'점심'/'저녁' 레이블을 리턴
String _labelFor(TimeOfDay t) {
  if (t.hour < 12) return '아침';
  if (t.hour < 18) return '점심';
  return '저녁';
}

class MediEndScreen extends StatefulWidget {
  final MediEndSelectionData selectionData;
  const MediEndScreen({Key? key, required this.selectionData})
      : super(key: key);

  @override
  State<MediEndScreen> createState() => _MediEndScreenState();
}

class _MediEndScreenState extends State<MediEndScreen> {
  late List<TimeOfDay> _alarmTimes;
  late List<String>   _dosageTimes;
  late int            _frequency;

  @override
  void initState() {
    super.initState();
    final sel = widget.selectionData;
    if (sel.prescribed) {
      _dosageTimes = List.from(sel.dosageTimes);
      _frequency   = _dosageTimes.length;
    } else {
      _dosageTimes = [];
      _frequency   = sel.frequency;
    }
    _alarmTimes = List.generate(
      _frequency,
          (_) => const TimeOfDay(hour: 8, minute: 0),
    );
  }

  void _onDosageChanged(List<String> newList) {
    setState(() {
      _dosageTimes = newList;
      _frequency   = newList.length;
      _alarmTimes  = List.generate(
        _frequency,
            (_) => const TimeOfDay(hour: 8, minute: 0),
      );
    });
  }

  void _onFrequencyChanged(int newFreq) {
    setState(() {
      _frequency   = newFreq;
      _dosageTimes = [];
      _alarmTimes  = List.generate(
        newFreq,
            (_) => const TimeOfDay(hour: 8, minute: 0),
      );
    });
  }

  void _onTimeChanged(int idx, TimeOfDay t) {
    setState(() => _alarmTimes[idx] = t);
  }

  Future<void> _upload() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final sel = widget.selectionData;
    final dosage = sel.prescribed
        ? _dosageTimes
        : _alarmTimes.map(_labelFor).toList();

    final body = {
      'name' : sel.name,
      'characteristic': sel.characteristic,
      'startDate'    : sel.startDate,
      'duration'     : sel.duration,
      'frequency'    : _frequency,
      'prescribed'   : sel.prescribed,
      'dosageTimes'  : dosage,
      'alarmTimes'   : _alarmTimes.map((t) {
        final base = DateTime.parse(sel.startDate);
        return DateFormat('HH:mm:ss')
            .format(DateTime(base.year, base.month, base.day, t.hour, t.minute));
      }).toList(),
    };

    final uri = Uri.parse('http://$ipAddress:8080/api/medicines');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    final jsonString = jsonEncode(body);
    req.files.add(
      http.MultipartFile.fromBytes(
        'data',
        utf8.encode(jsonString),
        contentType: MediaType('application', 'json'),
      ),
    );


    final streamed = await req.send();
    final res      = await http.Response.fromStream(streamed);

    if (res.statusCode == 200) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: ${res.statusCode}\n${res.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediEndAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Text(
              widget.selectionData.prescribed
                  ? '마지막이에요! 복용 시간대와 알림 받을 시간을 선택해주세요.'
                  : '마지막이에요! 하루에 몇 번 드실까요? 알림 받을 시간을 선택해주세요.',
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 처방약 vs. 일반약 UI 분기
            if (widget.selectionData.prescribed) ...[
              const Text('복용 시간대',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DosageSelector(
                options: const ['아침', '점심', '저녁'],
                selected: _dosageTimes,
                onChanged: _onDosageChanged,
              ),
            ] else ...[
              const Text('복용 주기',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FrequencySelector(
                value: _frequency,
                onChanged: _onFrequencyChanged,
              ),
            ],

            const SizedBox(height: 24),
            const Text('알림 시간',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TimeListPicker(
              times: _alarmTimes,
              onTimeChanged: _onTimeChanged,
            ),

            const SizedBox(height: 40),
            SubmitButton(onPressed: _upload),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
