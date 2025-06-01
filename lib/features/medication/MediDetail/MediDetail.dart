/*

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 달력 모듈의 Medicine/Alarm 숨기기
import 'package:medife/features/calendar/calendar.dart' hide Medicine, Alarm;

import '../MediMain/model/medimain_medicine.dart';
<<<<<<< HEAD
import '../MediEdit/MediEdit.dart';
=======
import '../MediMain/model/medimain_alarm.dart';
import 'package:medife/features/medication/MediEdit/MediEdit.dart';
import 'package:medife/components/custom_app_bar.dart';
>>>>>>> a2ca3c3c32efd5bba7fab38087c5b6845f99635a

class MediDetail extends StatefulWidget {
  final Medicine medicine;
  const MediDetail({Key? key, required this.medicine}) : super(key: key);

  @override
  _MediDetailState createState() => _MediDetailState();
}

class _MediDetailState extends State<MediDetail> {
  /// 화면에 표시할 로컬 복제 객체
  late Medicine _currentMedicine;

  /// 화면 표시용 가공된 값들
  late DateTime _startDate;
  late int _duration;
  late List<String> _dosageTimes; // ex) ["아침 07:00", "점심 12:00"]
  late String _frequency;         // ex) "2번"
  late TimeOfDay _alarmTime;      // 대표 알림 시간 (첫 번째 알람)

  @override
  void initState() {
    super.initState();
    // 1) widget.medicine 을 로컬 상태로 복제
    _currentMedicine = widget.medicine;
    // 2) 화면 표시용 값들을 계산
    _applyMedicine(_currentMedicine);
  }

  /// Medicine 객체를 화면용 값들로 변환
  void _applyMedicine(Medicine m) {
    final firstAlarm = m.alarms.first.alarmTime;
    _startDate = DateTime(
      firstAlarm.year,
      firstAlarm.month,
      firstAlarm.day,
    );
    // 복용 기간(일) = alarms.length
    if (m.prescribed) {
      _duration = m.duration;        // 서버에 저장된 duration 값을 사용
    } else {
      _duration = m.alarms.length;   // 기존처럼 알람 개수 사용
    }
    // 복용 시간대 리스트
    _dosageTimes = m.alarms.map((a) {
      return DateFormat('a hh:mm', 'ko_KR').format(a.alarmTime);
    }).toList();
    // 복용 주기: alarms 개수 + "번"
    _frequency = '${m.alarms.length}번';
    // 대표 알림 시간: 첫 알람의 TimeOfDay
    _alarmTime = TimeOfDay.fromDateTime(firstAlarm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '상세페이지',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // — 사진 + 이름 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF547EE8), width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  // 1) 이미지 표시(네트워크 또는 기본 아이콘)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _currentMedicine.imageUrl != null &&
                        _currentMedicine.imageUrl!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _currentMedicine.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(Icons.image, size: 35, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  // 2) 약 이름 및 characteristic (optional)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentMedicine.medicineName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentMedicine.characteristic,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildField(
              '복용 시작 날짜',
              DateFormat('yyyy-MM-dd').format(_startDate),
            ),
            _buildField('복용 기간', '$_duration일'),
            _buildField('복용 시간대', _dosageTimes.join(' / ')),
            _buildField('복용 주기', _frequency),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 주의사항 재생 로직 (필요 시 구현)
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('주의사항 재생하기'),
            ),
            const SizedBox(height: 12),

            // “정보 수정” 버튼: MediEdit 화면으로 이동 → 수정된 객체를 받으면 화면 갱신
            ElevatedButton(
              onPressed: () {
                Navigator.push<Medicine>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MediEdit(medicine: _currentMedicine),
                  ),
                ).then((updated) {
                  if (updated != null) {
                    setState(() {
                      // 1) 로컬 상태를 업데이트
                      _currentMedicine = updated;
                      // 2) 화면 표시용 필드를 다시 계산
                      _applyMedicine(_currentMedicine);
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('정보 수정'),
            ),
          ],
        ),
      ),
    );
  }

  /// "레이블: 값" 형태 한 줄 위젯
  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}


 */