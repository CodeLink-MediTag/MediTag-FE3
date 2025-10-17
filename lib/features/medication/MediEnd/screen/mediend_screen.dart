// lib/features/medication/MediEnd/screen/mediend_screen.dart
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

List<TimeOfDay> _makeDefaultTimes(int count) {
  switch (count) {
    case 1:
      return [const TimeOfDay(hour: 8, minute: 0)];
    case 2:
      return [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 18, minute: 0),
      ];
    case 3:
      return [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 12, minute: 0),
        const TimeOfDay(hour: 18, minute: 0),
      ];
    case 4:
      return [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 12, minute: 0),
        const TimeOfDay(hour: 18, minute: 0),
        const TimeOfDay(hour: 22, minute: 0),
      ];
    default:
      return [];
  }
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
  late List<String> _dosageTimes;
  late int _frequency;

  @override
  void initState() {
    super.initState();
    final sel = widget.selectionData;

    if (sel.prescribed) {
      // 처방약: 전달된 라벨 사용
      _dosageTimes = List.from(sel.dosageTimes);
      _frequency = _dosageTimes.length;
      _alarmTimes = _dosageTimes.map(_defaultTimeForLabel).toList();
    } else {
      _dosageTimes = [];
      _frequency = sel.frequency;
      _alarmTimes = List.generate(_frequency, (_) => const TimeOfDay(hour: 8, minute: 0));
    }
  }

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
      _frequency = newList.length;
      _alarmTimes = _dosageTimes.map(_defaultTimeForLabel).toList();
    });
  }

  void _onFrequencyChanged(int newFreq) {
    setState(() {
      _frequency = newFreq;
      _dosageTimes = [];
      _alarmTimes = _makeDefaultTimes(newFreq);
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
      'name': sel.name,
      'characteristic': sel.characteristic,
      'startDate': sel.startDate,
      'duration': sel.duration,
      'prescribed': sel.prescribed,
      'frequency': _frequency,
      'dosageTimes': sel.prescribed ? _dosageTimes : <String>[],
      'alarmTimes': _alarmTimes.map((t) {
        final base = DateTime.parse(sel.startDate);
        return DateFormat('HH:mm:ss').format(DateTime(base.year, base.month, base.day, t.hour, t.minute));
      }).toList(),
    };

    // debug
    print('📤 REQUEST BODY → ${jsonEncode(body)}');

    final uri = Uri.parse('http://$ipAddress/api/medicines');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile.fromBytes(
          'data',
          utf8.encode(jsonEncode(body)),
          contentType: MediaType('application', 'json'),
        ),
      );
    // 이미지 파일 추가
    if (sel.imageUrl != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'file',
          sel.imageUrl!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final pres = widget.selectionData.prescribed;

    return Scaffold(
      // 테마 기반 배경색 사용
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppBar(
          title: '등록 마무리',
          onBack: () => Navigator.of(context).pop(),
          onHome: () {
            Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
          },
        ),
      ),

      // SafeArea + ListView 로 스크롤/키보드 안전 보장
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Text(
                pres
                    ? '마지막이에요! 복용 시간대를 선택하고, 알림 받을 시간도 골라주세요.'
                    : '마지막이에요! 하루에 몇 번 드실까요? 알림 받을 시간을 선택해주세요.',
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 복용 시간대 또는 횟수 선택
              if (pres) ...[
                Text('복용 시간대', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // DosageSelector 내부가 테마를 따르도록 구현되어 있어야 함
                DosageSelector(
                  options: const ['아침', '점심', '저녁'],
                  selected: _dosageTimes,
                  onChanged: _onDosageChanged,
                ),
              ] else ...[
                Text('복용 주기', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                FrequencySelector(
                  value: _frequency,
                  onChanged: _onFrequencyChanged,
                ),
              ],

              const SizedBox(height: 24),

              // 공통: 알림 시간 선택
              Text('알림 시간', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TimeListPicker(
                times: _alarmTimes,
                onTimeChanged: _onTimeChanged,
              ),

              const SizedBox(height: 40),

              // 버튼은 테마 색을 강제로 넘겨서 일관성 유지
              // (CustomPrimaryButton 기본값이 하드코딩 돼 있으면
              //  backgroundColor: cs.primary 로 덮어쓰면 됨)
              CustomPrimaryButton(
                label: '등록',
                onPressed: _upload,
                // margin: padding은 ListView 안이므로 좌우 여백은 이미 고려됨.
                margin: const EdgeInsets.only(bottom: 20, top: 0),
                height: 48,
                borderRadius: 10,
                // 테마 기반 색 전달
                backgroundColor: cs.primary,
                // 버튼 텍스트 스타일을 테마의 onPrimary로 맞춤
                textStyle: theme.textTheme.titleMedium?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
