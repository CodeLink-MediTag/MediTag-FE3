/*

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../MediMain/model/medimain_medicine.dart';
import '../MediMain/model/medimain_alarm.dart';
import 'package:medife/ip/ip_address.dart';

// 커스텀 앱바 임포트 (경로 맞게 수정하세요)
import 'package:medife/components/custom_app_bar.dart';

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

    // 4) 시작 날짜: alarms 첫 번째 요소에서 연월일만 가져오기
    final firstAlarm = widget.medicine.alarms.first.alarmTime;
    _startDate = DateTime(firstAlarm.year, firstAlarm.month, firstAlarm.day);

    // 5) 알림 시간 리스트(TimeOfDay)
    _alarmTimes = widget.medicine.alarms
        .map((a) => TimeOfDay.fromDateTime(a.alarmTime))
        .toList();

    // 6) 복용 시간대(ChoiceChip) 선택 초기 상태
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
  Future<void> _pickTime(int idx) async {
    final t = await showTimePicker(
      context: context,
      initialTime: _alarmTimes[idx],
    );
    if (t != null) {
      // 중복 체크를 하자
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
      setState(() {
        _alarmTimes[idx] = t;
      });
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

  /// 저장 (PATCH 요청) ─────────────────────────────────────────────────────────
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
      _startDate.year,
      _startDate.month,
      _startDate.day,
    );
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

    // 2) 알림 시간을 서버에 보낼 문자열 리스트 ("HH:mm:ss" 형식)
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
      // 처방약이면 duration, 일반약이면 frequency (둘 중 하나만 null 처리)
      'duration': _prescribed ? int.parse(_durationCtrl.text) : null,
      'frequency': !_prescribed ? int.parse(_durationCtrl.text) : null,
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

    // 5) JSON 데이터 파트 추가 (@RequestPart("data"))
    req.files.add(
      http.MultipartFile.fromString(
        'data', // 백엔드 @RequestPart("data") 와 동일해야 함
        jsonEncode(bodyJson),
        contentType: MediaType('application', 'json'),
      ),
    );

    // 6) 이미지 파일 파트 추가(선택사항) (@RequestPart("file"))
    if (_pickedImage != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'file', // 백엔드 @RequestPart("file") 와 동일해야 함
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
        // 8) 응답이 JSON이면 파싱해서 Medicine 객체 생성 후 pop, 아니면 로컬 객체 그대로 pop

        // 8-1) 서버가 JSON 형태(수정된 Medicine 전체 데이터)를 리턴하는 경우
        try {
          final updatedJson = jsonDecode(res.body) as Map<String, dynamic>;
          final updatedModel = Medicine.fromJson(updatedJson);
          Navigator.pop(context, updatedModel);
          return;
        } catch (_) {
          // JSON 파싱 실패 → plain-text 응답으로 간주
        }

        // 8-2) 서버가 plain-text("약 정보와 알림이 성공적으로 수정되었습니다.")를 리턴하는 경우:
        // 이미 로컬에 맞게 만든 newAlarms를 이용해서 새 모델을 만들어서 pop
        final updatedMedicine = Medicine(
          medicineId: widget.medicine.medicineId,
          medicineName: _nameCtrl.text,
          characteristic: widget.medicine.characteristic,
          imageUrl: widget.medicine.imageUrl,
          prescribed: _prescribed,
          duration: int.parse(_durationCtrl.text),
          frequency: _prescribed
              ? null
              : int.parse(_durationCtrl.text),
          alarms: newAlarms,
          isFavorite: widget.medicine.isFavorite,
        );
        Navigator.pop(context, updatedMedicine);

      } else {
        // HTTP 200이 아니면 에러 처리
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
      appBar: CustomAppBar(
        title: '정보 수정',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ 약 이름 입력
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: '약 이름'),
            ),

            const SizedBox(height: 24),

            // ─ 복용 시작 날짜
            ListTile(
              title: Text(
                '복용 시작 날짜: ${DateFormat('yyyy-MM-dd').format(_startDate)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),

            const SizedBox(height: 24),

            // ─ 복용 기간 (일) 또는 복용 횟수 (일반약)
            TextField(
              controller: _durationCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '복용 기간 (일)'),
            ),

            const SizedBox(height: 24),

            // ─ 처방약일 때만 “복용 시간대” 선택
            if (_prescribed) ...[
              const Text(
                '복용 시간대',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _dosageOptions.map((opt) {
                  return ChoiceChip(
                    label: Text(opt),
                    selected: _selectedDosage.contains(opt),
                    onSelected: (sel) {
                      setState(() {
                        if (sel) {
                          _selectedDosage.add(opt);
                        } else {
                          _selectedDosage.remove(opt);
                        }

                        // 복용 시간대 개수에 맞게 알림 시간 개수 조절
                        if (_selectedDosage.length > _alarmTimes.length) {
                          // 새로 추가할 때 기본 시간 08:00 으로 세팅
                          _alarmTimes.add(const TimeOfDay(hour: 8, minute: 0));
                        } else if (_selectedDosage.length < _alarmTimes.length) {
                          _alarmTimes.removeLast();
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // ─ 알림 시간 (선택된 복용 시간대 수만큼 ListTile 생성)
            const Text(
              '알림 시간',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(_alarmTimes.length, (i) {
              final label = _prescribed
                  ? _selectedDosage[i] + ':'
                  : '시간 ${i + 1}:';
              return ListTile(
                title: Text('$label ${_alarmTimes[i].format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(i),
              );
            }),

            const SizedBox(height: 16),

            // ─ 이미지 선택 (선택사항)
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('이미지 선택'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                if (_pickedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _pickedImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // ─ 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF547EE8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




 */