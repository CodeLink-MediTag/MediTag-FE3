import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/ip/ip_address.dart';

import '../model/mediend_selection_data.dart';
import '../component/mediend_dosage_selector.dart';
import '../component/mediend_frequency_selector.dart';
import '../component/mediend_time_list.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/components/custom_primary_button.dart';

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
      // ▶ 처방약: 사용자가 넘겨준 dosageTimes 라벨 목록 그대로 가져오기
      _dosageTimes = List.from(sel.dosageTimes);
      _frequency   = _dosageTimes.length;
      // “dosageTimes = [‘아침’,‘저녁’]”이라면, 여기에 매핑되는 알람 시간 생성
      _alarmTimes  = _dosageTimes.map(_defaultTimeForLabel).toList();
    } else {
      // ▶ 일반약: frequency 만큼 아무 값 없이 초기화해두고
      _dosageTimes = [];
      _frequency   = sel.frequency;
      // 일반약은 나중에 FrequencySelector를 통해 변경하므로, 기본 예시로 오후 8시 하나만 넣어둘 수도 있고,
      // 그냥 빈 리스트로 두고, FrequencySelector 콜백에서 채워도 됩니다.
      _alarmTimes = List.generate(_frequency, (_) => const TimeOfDay(hour: 8, minute: 0));
    }
  }

  /// “아침/점심/저녁” 라벨을 → 기본 시간으로 매핑해 주는 헬퍼 함수
  TimeOfDay _defaultTimeForLabel(String label) {
    switch (label) {
      case '아침':
        return const TimeOfDay(hour: 8, minute: 0);
      case '점심':
        return const TimeOfDay(hour: 12, minute: 0);
      case '저녁':
        return const TimeOfDay(hour: 18, minute: 0);
      default:
        return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  void _onDosageChanged(List<String> newList) {
    setState(() {
      _dosageTimes = newList;
      _frequency   = newList.length;
      _alarmTimes  = _dosageTimes.map(_defaultTimeForLabel).toList();
    });
  }

  void _onFrequencyChanged(int newFreq) {
    setState(() {
      _frequency   = newFreq;
      _dosageTimes = [];
      _alarmTimes  = List.generate(newFreq, (_) => const TimeOfDay(hour: 8, minute: 0));
    });
  }

  void _onTimeChanged(int idx, TimeOfDay picked) {
    bool isDuplicate = _alarmTimes.any((t) => t.hour == picked.hour && t.minute == picked.minute);
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 동일한 시간이 등록되어 있습니다.'), duration: Duration(seconds: 2)),
      );
      return;
    }
    setState(() {
      _alarmTimes[idx] = picked;
    });
  }


  Future<void> _upload() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final sel = widget.selectionData;
    final body = <String, dynamic>{
      'name'          : sel.name,
      'characteristic': sel.characteristic,
      'startDate'     : sel.startDate,
      'duration'      : sel.duration,
      'prescribed'    : sel.prescribed,
      // 언제나 frequency 보내기
      'frequency'     : _frequency,
      // 언제나 dosageTimes 보내기 (처방약엔 실제 값, 일반약엔 빈 배열)
      'dosageTimes'   : sel.prescribed ? _dosageTimes : <String>[],
      // 언제나 alarmTimes 보내기
      'alarmTimes'    : _alarmTimes.map((t) {
        final base = DateTime.parse(sel.startDate);
        return DateFormat('HH:mm:ss').format(
          DateTime(base.year, base.month, base.day, t.hour, t.minute),
        );
      }).toList(),
    };

    // 디버깅: 실제 보내는 페이로드를 로그로 확인
    print('📤 REQUEST BODY → ${jsonEncode(body)}');

    final uri = Uri.parse('http://$ipAddress:8080/api/medicines');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile.fromBytes(
          'data',
          utf8.encode(jsonEncode(body)),
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
    final pres = widget.selectionData.prescribed;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppBar(
          title: '등록 마무리',
          onBack: () => Navigator.of(context).pop(),
          onHome: () {
            Navigator.pushNamedAndRemoveUntil(
                context,
                '/landing',
                    (route) => false // 스택을 깨끗하게 비우기
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Text(
              pres
                  ? '마지막이에요! 복용 시간대를 선택하고, 알림 받을 시간도 골라주세요.'
                  : '마지막이에요! 하루에 몇 번 드실까요? 알림 받을 시간을 선택해주세요.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 복용 시간대 또는 횟수 선택
            if (pres) ...[
              const Text('복용 시간대',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DosageSelector(
                options: const ['아침', '점심', '저녁'],
                selected: _dosageTimes,
                onChanged: _onDosageChanged,
              ),
            ] else ...[
              const Text('복용 주기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FrequencySelector(
                value: _frequency,
                onChanged: _onFrequencyChanged,
              ),
            ],

            const SizedBox(height: 24),

            // **공통으로 알림 시간 고르는 UI**
            const Text('알림 시간',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TimeListPicker(
              times: _alarmTimes,
              onTimeChanged: _onTimeChanged,
            ),

            const SizedBox(height: 40),
            CustomPrimaryButton(
              label: '등록',
              onPressed: _upload,
              margin: const EdgeInsets.only(bottom: 20, top: 0, left: 16, right: 16),
              height: 48,
              borderRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
