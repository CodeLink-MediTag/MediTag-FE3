// lib/features/medication/MediDetail/screen/medidetail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../component/medidetail_header.dart';
import '../component/medidetail_field_row.dart';
import '../component/medidetail_action_buttons.dart';
import '../../MediMain/model/medimain_medicine.dart';
import '../../MediEdit/screen/mediedit_screen.dart';
import 'package:medife/features/calendar/calendar.dart' hide Medicine, Alarm;
import 'package:medife/components/custom_app_bar.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      // 명시적으로 테마의 scaffoldBackgroundColor 사용 (안전)
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          title: '상세페이지',
          onBack: () => Navigator.of(context).pop(_currentMedicine),
          onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 카드처럼 보이는 컨테이너: 색과 테두리는 theme에서 가져오도록 변경
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // 카드 배경은 theme.cardColor 사용 (다크/라이트에 맞음)
                color: theme.cardColor,
                // 테두리는 colorScheme.primary (브랜드 색을 테마에서 가져옴)
                border: Border.all(color: cs.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
                // 그림자도 theme.shadowColor 기준으로 약하게 줌
                boxShadow: [
                  BoxShadow(color: theme.shadowColor.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1) 헤더 (이미 테마 기반으로 작성된 위젯)
                  MediDetailHeader(
                    imageUrl: _currentMedicine.imageUrl ?? '',
                    medicineName: _currentMedicine.medicineName,
                    isPrescription: _currentMedicine.isPrescription,
                  ),
                  const SizedBox(height: 20),

                  // 2) 필드 행들 (FieldRow는 테마 기반으로 수정되어 있음)
                  FieldRow(
                    label: '복용 시작 날짜',
                    value: DateFormat('yyyy-MM-dd').format(_startDate),
                  ),
                  FieldRow(label: '복용 기간', value: '$_duration일'),
                  FieldRow(label: '복용 주기', value: _frequency),
                  FieldRow(label: '복용 시간대', value: _dosageTimes.join(' / ')),

                  // 녹음파일 정보
                  FieldRow(
                    label: '주의사항 파일',
                    value: widget.medicine.characteristic,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3) 액션 버튼들 (MediDetailActions도 테마 기반으로 수정되어 있음)
            MediDetailActions(
              medicine: _currentMedicine,
              onEdited: (updatedMedicine) {
                setState(() {
                  _currentMedicine = updatedMedicine;
                  _applyMedicine(updatedMedicine);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
