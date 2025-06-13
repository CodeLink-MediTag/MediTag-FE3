import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/mediedit_name_field.dart';
import '../component/mediedit_startdate_field.dart';
import '../component/mediedit_duration_field.dart';
import '../component/mediedit_dosageselector_field.dart';
import '../component/mediedit_alarmtime_list.dart';
import '../component/mediedit_imagepicker_field.dart';
import '../component/mediedit_submit_button.dart';
import '../../MediMain/model/medimain_alarm.dart';
import '../../MediMain/model/medimain_medicine.dart';
import 'package:medife/ip/ip_address.dart';
import 'package:medife/components/custom_app_bar.dart';

/// “아침/점심/저녁” 라벨을 기본 시간으로 매핑해 주는 헬퍼 함수
TimeOfDay _defaultTimeForLabel(String label) {
  switch (label) {
    case '아침':
      return const TimeOfDay(hour: 8, minute: 0);
    case '점심':
      return const TimeOfDay(hour: 12, minute: 0);
    case '저녁':
      return const TimeOfDay(hour: 18, minute: 0);
    default:
    // 예기치 않은 경우에는 오전 8시로
      return const TimeOfDay(hour: 8, minute: 0);
  }
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
      return [const TimeOfDay(hour: 8, minute: 0)];
  }
}


class MediEditScreen extends StatefulWidget {
  final Medicine medicine;
  const MediEditScreen({Key? key, required this.medicine}) : super(key: key);

  @override
  _MediEditScreenState createState() => _MediEditScreenState();
}

class _MediEditScreenState extends State<MediEditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _durationCtrl;
  late int _frequencyCount;
  late DateTime _startDate;
  late List<TimeOfDay> _alarmTimes;
  late bool _prescribed;
  final List<String> _dosageOptions = ['아침', '점심', '저녁'];
  late List<String> _selectedDosage;
  File? _pickedImage;

  /// TimePicker 에서 리턴된 시간을 바로 반영해 주는 콜백
  void _onAlarmTimeChanged(int idx, TimeOfDay newTime) {
    // 중복 검사
    if (_alarmTimes.any((t) => t.hour == newTime.hour && t.minute == newTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 동일한 시간이 있습니다.'), duration: Duration(seconds: 2)),
      );
      return;
    }
    setState(() {
      _alarmTimes[idx] = newTime;
    });
  }

  @override
  void initState() {
    super.initState();

    // 1) 서버에서 받은 실제 alarms 그대로 TimeOfDay 로 변환해서 저장
    _alarmTimes = widget.medicine.alarms
        .map((a) => TimeOfDay.fromDateTime(a.alarmTime))
        .toList();

    // 2) 처방약 여부 세팅
    _prescribed = widget.medicine.prescribed;

    // 3) 처방약이면, 서버에서 내려준 alarms 의 라벨만 뽑아서 저장 (버튼 선택 상태 복원용)
    if (_prescribed) {
      _selectedDosage = widget.medicine.alarms.map((a) {
        var h = TimeOfDay
            .fromDateTime(a.alarmTime)
            .hour;
        if (h < 12) return '아침';
        if (h < 18) return '점심';
        return '저녁';
      }).toList();
    } else {
      _selectedDosage = [];
    }

    // 약 이름 컨트롤러
    _nameCtrl = TextEditingController(text: widget.medicine.medicineName);

    // 복용 기간 컨트롤러: (처방약이면 서버의 duration, 일반약이면 alarms.length)로 초기값 세팅
    _durationCtrl =
        TextEditingController(text: widget.medicine.duration.toString());

    _frequencyCount =
        widget.medicine.frequency ?? widget.medicine.alarms.length;

    var first = widget.medicine.alarms.first.alarmTime;
    _startDate = DateTime(first.year, first.month, first.day);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  /// 날짜 선택 다이얼로그
  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() => _startDate = d);
    }
  }

  /// 시간 선택 다이얼로그 (알림 시간)
  Future<void> _pickTime(int idx) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _alarmTimes[idx],
    );
    if (picked != null) {
      // 중복 검사
      if (_alarmTimes.any((t) =>
      t.hour == picked.hour && t.minute == picked.minute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 동일한 시간이 있습니다.'),
              duration: Duration(seconds: 2)),
        );
        return;
      }
      setState(() => _alarmTimes[idx] = picked);
    }
  }


  /// 갤러리에서 이미지 선택
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _pickedImage = File(file.path);
      });
    }
  }

  /// 저장 (PATCH 요청)
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 정보가 없습니다.')),
      );
      return;
    }

    // 1) TimeOfDay 리스트 → Alarm 객체 리스트
    final baseDate = DateTime(
        _startDate.year, _startDate.month, _startDate.day);
    final newAlarms = _alarmTimes
        .map((tod) =>
        Alarm(
          alarmTime: DateTime(
            baseDate.year,
            baseDate.month,
            baseDate.day,
            tod.hour,
            tod.minute,
          ),
          taking: false,
        ))
        .toList();

    // 2) 알림 시간을 서버에 보낼 문자열 리스트 ("HH:mm:ss")
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final alarmStrings = _alarmTimes.map((tod) {
      final h = twoDigits(tod.hour);
      final m = twoDigits(tod.minute);
      return '$h:$m:00';
    }).toList();

    // 3) JSON Body 생성 (백엔드 DTO 필드명에 맞추기)
    final Map<String, dynamic> bodyJson = {
      'name': _nameCtrl.text,
      'characteristic': widget.medicine.characteristic,
      'startDate': DateFormat('yyyy-MM-dd').format(_startDate),
      'duration': int.parse(_durationCtrl.text),
      'frequency': _prescribed ? null : _frequencyCount,
      'prescribed': _prescribed,
      'dosageTimes': _prescribed ? _selectedDosage : <String>[],
      'alarmTimes': alarmStrings,
    };

    // 4) MultipartRequest 구성
    final uri = Uri.parse(
      'http://$ipAddress:8080/api/medicines/${widget.medicine.medicineId}',
    );
    final req = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $token';

    // 5) JSON 데이터 파트 추가
    req.files.add(
      http.MultipartFile.fromString(
        'data',
        jsonEncode(bodyJson),
        contentType: MediaType('application', 'json'),
      ),
    );

    // 6) 이미지 파일 파트 추가(선택사항)
    if (_pickedImage != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _pickedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    // 7) 요청 전송
    try {
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        // (8-1) JSON으로 수정된 Medicine을 리턴받는 경우
        try {
          final updatedJson = jsonDecode(res.body) as Map<String, dynamic>;
          final updatedModel = Medicine.fromJson(updatedJson);
          Navigator.pop(context, updatedModel);
          return;
        } catch (_) {
          // JSON 파싱 실패 → plain-text 응답으로 간주
        }

        // (8-2) plain-text("성공") 응답인 경우
        final updatedMedicine = Medicine(
          medicineId: widget.medicine.medicineId,
          medicineName: _nameCtrl.text,
          characteristic: widget.medicine.characteristic,
          imageUrl: widget.medicine.imageUrl,
          isPrescription: _prescribed,
          prescribed: _prescribed,
          duration: int.parse(_durationCtrl.text),
          frequency: _prescribed ? null : _frequencyCount,
          alarms: newAlarms,
          isFavorite: widget.medicine.isFavorite,
        );
        Navigator.pop(context, updatedMedicine);
      } else {
        // HTTP 200 이외 → 에러
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '정보 수정 실패 (${res.statusCode}):\n${res.body}',
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류 발생: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          title: '정보 수정',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) 약 이름
            NameField(controller: _nameCtrl),

            const SizedBox(height: 24),

            // 2) 복용 시작 날짜
            StartDateField(startDate: _startDate, onTap: _pickDate),

            const SizedBox(height: 24),

            // 3) 복용 기간
            DurationField(controller: _durationCtrl),

            const SizedBox(height: 24),

            // (4-1) 일반약 모드: 1~4회 ChoiceChip
            if (!_prescribed) ...[
              const Text('복용 주기', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(4, (i) {
                  final cnt = i + 1;
                  return ChoiceChip(
                    label: Text('$cnt회'),
                    selected: _frequencyCount == cnt,
                    onSelected: (sel) {
                      if (!sel) return;
                      setState(() {
                      _frequencyCount = cnt;
                      // 주기 변경 시 알람시간 기본값 재설정
                      _alarmTimes = _makeDefaultTimes(cnt);
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
            ],

            // (4-2) 처방약 모드: 아침/점심/저녁 ChoiceChip
            if (_prescribed) ...[
              const Text('복용 시간대', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _dosageOptions.map((label) {
                  final isSelected = _selectedDosage.contains(label);
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (sel) {
                      setState(() {
                        if (sel) {
                          _selectedDosage.add(label);
                          _alarmTimes.add(_defaultTimeForLabel(label));
                        } else {
                          final idx = _selectedDosage.indexOf(label);
                          _selectedDosage.removeAt(idx);
                          _alarmTimes.removeAt(idx);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // (5) 알림 시간 리스트
            AlarmTimeListField(
              times: _alarmTimes,
              onTapAt: (idx) async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _alarmTimes[idx],
                );
                if (picked == null) return;
                // 중복 검사
                if (_alarmTimes.any((t) => t.hour == picked.hour && t.minute == picked.minute)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('이미 동일한 시간이 있습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                setState(() {
                  _alarmTimes[idx] = picked;
                });
              },
            ),

            const SizedBox(height: 24),

            // 6) 이미지 선택
            ImagePickerField(
              pickedImage: _pickedImage,
              onPickImage: _pickImageFromGallery,
            ),

            const SizedBox(height: 32),

            // 7) 저장 버튼
            SubmitButton(onPressed: _save),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
