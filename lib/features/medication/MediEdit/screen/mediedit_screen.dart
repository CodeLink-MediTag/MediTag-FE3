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

class MediEditScreen extends StatefulWidget {
  final Medicine medicine;
  const MediEditScreen({Key? key, required this.medicine}) : super(key: key);

  @override
  _MediEditScreenState createState() => _MediEditScreenState();
}

class _MediEditScreenState extends State<MediEditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _durationCtrl;
  late DateTime _startDate;
  late List<TimeOfDay> _alarmTimes;
  late bool _prescribed;
  final List<String> _dosageOptions = ['아침', '점심', '저녁'];
  late List<String> _selectedDosage;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();

    // 1) 약 이름 컨트롤러
    _nameCtrl = TextEditingController(text: widget.medicine.medicineName);

    // 2) 복용 기간 컨트롤러: (처방약이면 서버의 duration, 일반약이면 alarms.length)로 초기값 세팅
    _durationCtrl = TextEditingController(
      text: widget.medicine.prescribed
          ? widget.medicine.duration.toString()
          : widget.medicine.alarms.length.toString(),
    );

    // 3) 처방약 여부
    _prescribed = widget.medicine.prescribed;

    // 4) 시작 날짜: alarms 첫 번째 요소에서 연/월/일만 가져오기
    final firstAlarm = widget.medicine.alarms.first.alarmTime;
    _startDate = DateTime(firstAlarm.year, firstAlarm.month, firstAlarm.day);

    // 4) “처방약 여부”에 따라 _selectedDosage, _alarmTimes 초기화
    if (_prescribed) {
      // ▶ 처방약: 서버에서 내려준 alarms 로부터 라벨(아침/점심/저녁)만 뽑아서 _selectedDosage에 저장
      _selectedDosage = widget.medicine.alarms.map((a) {
        final hour = TimeOfDay.fromDateTime(a.alarmTime).hour;
        if (hour < 12) return '아침';
        if (hour < 18) return '점심';
        return '저녁';
      }).toList();

      // 라벨 순서대로 기본 시간으로 매핑 → _alarmTimes에 저장
      _alarmTimes = _selectedDosage.map(_defaultTimeForLabel).toList();
    } else {
      // ▶ 일반약: 서버에서는 알람 개수만 주기 때문에, alarms.length만큼 08:00으로 초기화
      _selectedDosage = [];
      _alarmTimes = List.generate(
        widget.medicine.alarms.length,
            (_) => const TimeOfDay(hour: 8, minute: 0),
      );
    }
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
  Future<void> _pickTime(int idx, TimeOfDay _unused) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _alarmTimes[idx],
    );
    if (picked != null) {
      // 중복 검사
      bool alreadyExists = _alarmTimes.any((existing) {
        return existing.hour == picked.hour && existing.minute == picked.minute;
      });
      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 동일한 시간이 있습니다.'),
            duration: Duration(seconds: 2),
          ),
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
    final baseDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final newAlarms = _alarmTimes
        .map((tod) => Alarm(
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
      'frequency': _prescribed ? null : int.parse(_durationCtrl.text),
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
          prescribed: _prescribed,
          duration: int.parse(_durationCtrl.text),
          frequency: _prescribed ? null : int.parse(_durationCtrl.text),
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
      appBar: AppBar(
        title: const Text('정보 수정'),
        backgroundColor: const Color(0xFF547EE8),
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

            // 4) 처방약일 때만 “복용 시간대” 선택
            if (_prescribed) ...[
              const SizedBox(height: 8),
              DosageSelectorField(
                options: _dosageOptions,
                selected: _selectedDosage,
                onChanged: (newList) {
                  setState(() {
                    _selectedDosage = newList;
                    // 수정된 로직: 선택된 라벨 순서대로 매번 기본 시간으로 매핑
                    _alarmTimes = _selectedDosage.map(_defaultTimeForLabel).toList();
                  });
                },
              ),

              const SizedBox(height: 24),
            ],

            // 5) 알림 시간 리스트
            AlarmTimeListField(times: _alarmTimes, onTimeChanged: _pickTime),

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

/*
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


class MediEditScreen extends StatefulWidget {
  final Medicine medicine;
  const MediEditScreen({Key? key, required this.medicine}) : super(key: key);

  @override
  _MediEditScreenState createState() => _MediEditScreenState();
}

class _MediEditScreenState extends State<MediEditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _durationCtrl;
  late DateTime _startDate;
  late List<TimeOfDay> _alarmTimes;
  late bool _prescribed;
  final List<String> _dosageOptions = ['아침', '점심', '저녁'];
  late List<String> _selectedDosage;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();

    // 1) 약 이름 컨트롤러
    _nameCtrl = TextEditingController(text: widget.medicine.medicineName);

    // 2) 복용 기간 컨트롤러: (처방약이면 서버의 duration, 일반약이면 alarms.length)로 초기값 세팅
    _durationCtrl = TextEditingController(
      text: widget.medicine.prescribed
          ? widget.medicine.duration.toString()
          : widget.medicine.alarms.length.toString(),
    );

    // 3) 처방약 여부
    _prescribed = widget.medicine.prescribed;

    // 4) 시작 날짜: alarms 첫 번째 요소에서 연/월/일만 가져오기
    final firstAlarm = widget.medicine.alarms.first.alarmTime;
    _startDate = DateTime(firstAlarm.year, firstAlarm.month, firstAlarm.day);

    // 5) 알림 시간 리스트(TimeOfDay)
    _alarmTimes =
        widget.medicine.alarms.map((a) => TimeOfDay.fromDateTime(a.alarmTime)).toList();

    // 6) 복용 시간대(ChoiceChip) 선택 초기 상태 (처방약일 때만)
    _selectedDosage = widget.medicine.alarms.map((a) {
      final hour = TimeOfDay.fromDateTime(a.alarmTime).hour;
      if (hour < 12) return '아침';
      if (hour < 18) return '점심';
      return '저녁';
    }).toList();
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
  void _pickTime(int idx, TimeOfDay t) async {
    final t = await showTimePicker(
      context: context,
      initialTime: _alarmTimes[idx],
    );
    if (t != null) {
      // 중복 체크
      bool alreadyExists = _alarmTimes.any((existing) {
        return existing.hour == t.hour && existing.minute == t.minute;
      });
      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 동일한 시간이 있습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      setState(() => _alarmTimes[idx] = t);
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
    final baseDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final newAlarms = _alarmTimes
        .map((tod) => Alarm(
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
      'frequency': _prescribed ? null : int.parse(_durationCtrl.text),
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
          prescribed: _prescribed,
          duration: int.parse(_durationCtrl.text),
          frequency: _prescribed ? null : int.parse(_durationCtrl.text),
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
      appBar: AppBar(
        title: const Text('정보 수정'),
        backgroundColor: const Color(0xFF547EE8),
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

            // 4) 처방약일 때만 “복용 시간대” 선택
            if (_prescribed) ...[
              const SizedBox(height: 8),
              DosageSelectorField(
                options: _dosageOptions,
                selected: _selectedDosage,
                onChanged: (newList) {
                  setState(() {
                    _selectedDosage = newList;
                    if (_selectedDosage.length > _alarmTimes.length) {
                      _alarmTimes.add(const TimeOfDay(hour: 8, minute: 0));
                    } else if (_selectedDosage.length < _alarmTimes.length) {
                      _alarmTimes.removeLast();
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
            ],

            // 5) 알림 시간 리스트
            AlarmTimeListField(times: _alarmTimes, onTimeChanged: _pickTime),

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

 */