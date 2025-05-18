import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 달력 모듈의 Medicine/Alarm 숨기기
import 'package:medife/features/calendar/calendar.dart' hide Medicine, Alarm;

import '../MediMain/model/medimain_medicine.dart';
import '../MediMain/model/medimain_alarm.dart';
import 'package:medife/features/medication/MediEdit/MediEdit.dart';

class MediDetail extends StatefulWidget {
  final Medicine? medicine; // nullable로 변경
  const MediDetail({Key? key, this.medicine}) : super(key: key);

  @override
  _MediDetailState createState() => _MediDetailState();
}

class _MediDetailState extends State<MediDetail> {
  late DateTime _startDate;
  late int _duration;
  late List<String> _dosageTimes;
  late String _frequency;
  late TimeOfDay _alarmTime;

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _applyMedicine(widget.medicine!);
    }
  }

  void _applyMedicine(Medicine m) {
    _startDate = m.alarms.first.alarmTime;
    _duration = m.alarms.length;
    _dosageTimes = m.alarms
        .map((a) => DateFormat('a hh:mm', 'ko_KR').format(a.alarmTime))
        .toList();
    _frequency = '${m.alarms.length}번';
    _alarmTime = TimeOfDay.fromDateTime(m.alarms.first.alarmTime);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.medicine == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('상세페이지'),
          backgroundColor: const Color(0xFF547EE8),
        ),
        body: const Center(
          child: Text(
            '약 정보가 없습니다.\n약을 먼저 등록해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('상세페이지'),
        backgroundColor: const Color(0xFF547EE8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // — 사진+이름 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF547EE8), width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.medicine!.imageUrl != null &&
                        widget.medicine!.imageUrl!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.medicine!.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(
                      Icons.image,
                      size: 35,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.medicine!.medicineName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
            _buildField('알림 시간', _alarmTime.format(context)),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: 주의사항 재생 로직
              },
              style:
              ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('주의사항 재생하기'),
            ),
            const SizedBox(height: 12),

            // 정보 수정 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push<Medicine>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MediEdit(medicine: widget.medicine!),
                  ),
                ).then((updated) {
                  if (updated != null) {
                    setState(() {
                      _applyMedicine(updated);
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

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}