import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:medife/features/medication/MediStart/model/medistart_selection_data.dart';
import 'package:medife/features/medication/MediEnd/model/mediend_selection_data.dart';
import 'package:medife/features/medication/MediEnd/screen/mediend_screen.dart';

import '../component/medimiddle_app_bar.dart';
import '../component/medimiddle_period_selector.dart';
import '../component/medimiddle_date_picker.dart';
import '../component/medimiddle_duration_input.dart';
import '../component/medimiddle_next_button.dart';

class MediMiddleScreen extends StatefulWidget {
  final MediStartSelectionData selectionData;
  const MediMiddleScreen({Key? key, required this.selectionData}) : super(key: key);

  @override
  _MediMiddleScreenState createState() => _MediMiddleScreenState();
}

class _MediMiddleScreenState extends State<MediMiddleScreen> {
  DateTime selectedDate = DateTime.now();
  int? selectedPeriod;               // 1=특정일, 2=매일
  final TextEditingController customDaysController = TextEditingController();

  // → 새로 추가한 변수: 처방약 체크 여부
  bool _isPrescribed = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _onNext() async {
    // 주기 선택을 안 했으면 스낵바
    if (selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('복용 기간을 선택해주세요.')),
      );
      return;
    }

    // 복용 기간(days) 계산
    late int days;
    if (selectedPeriod == 1) {
      final parsed = int.tryParse(customDaysController.text);
      if (parsed == null || parsed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('복용 기간을 올바르게 입력해주세요.')),
        );
        return;
      }
      days = parsed;
    } else {
      days = 30;
    }

    // checkbox 로 넘어온 처방약 여부 사용
    final prescribed = _isPrescribed;

    // MediEndScreen 으로 보낼 데이터 준비
    final mid = widget.selectionData;
    final endData = MediEndSelectionData(
      name:           mid.name,
      characteristic: mid.characteristic,
      startDate:      DateFormat('yyyy-MM-dd').format(selectedDate),
      duration:       days,
      frequency:      // 처방약이면 고정 3회, 아니면 일단 빈 값(EndScreen 에서 사용자가 선택)
      prescribed ? 3 : 0,
      imageUrl:       mid.imageUrl,
      prescribed:     prescribed,
      dosageTimes:    // 처방약이면 기본 ['아침','점심','저녁'], 아니면 빈 리스트
      prescribed ? ['아침','점심','저녁'] : [],
      alarmTimes:     [], // EndScreen 에서 채워짐
    );

    final bool? endResult = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MediEndScreen(selectionData: endData)),
    );

    if (endResult == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MediMiddleAppBar(),
      backgroundColor: const Color(0xFFF3F5FA),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  '복용 기간, 시작 날짜를 입력해주세요!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                const Text('복용 기간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                MediMiddlePeriodSelector(
                  selectedPeriod: selectedPeriod,
                  onChanged: (v) => setState(() => selectedPeriod = v),
                ),

                const SizedBox(height: 20),
                const Text('복용 시작 날짜', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                MediMiddleDatePicker(selectedDate: selectedDate, onTap: _selectDate),

                const SizedBox(height: 28),
                MediMiddleDurationInput(
                  visible: selectedPeriod == 1,
                  controller: customDaysController,
                ),

                const SizedBox(height: 20),
                // ★ 추가: 처방약 체크박스
                CheckboxListTile(
                  title: const Text('처방약인가요?'),
                  value: _isPrescribed,
                  onChanged: (v) => setState(() => _isPrescribed = v!),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),

          MediMiddleNextButton(onPressed: _onNext),
        ],
      ),
    );
  }
}

