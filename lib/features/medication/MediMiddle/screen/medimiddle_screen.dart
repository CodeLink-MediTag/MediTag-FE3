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
    if (selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('복용 주기를 선택해주세요.')),
      );
      return;
    }

    // 기간(days)와 prescribed 여부 계산
    late int days;
    late bool prescribed;
    if (selectedPeriod == 1) {
      final parsed = int.tryParse(customDaysController.text);
      if (parsed == null || parsed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('복용 기간을 올바르게 입력해주세요.')),
        );
        return;
      }
      days = parsed;
      prescribed = true;
    } else {
      days = 30;
      prescribed = false;
    }

    // Start → End 로 데이터 매핑
    final mid = widget.selectionData;
    final endData = MediEndSelectionData(
      name:           mid.name,
      characteristic: mid.characteristic,
      startDate:      DateFormat('yyyy-MM-dd').format(selectedDate),
      duration:       days,
      frequency:      prescribed ? 3 : days,
      imageUrl:       mid.imageUrl,
      prescribed:     prescribed,
      dosageTimes:    prescribed ? ['아침','점심','저녁'] : [],
      alarmTimes:     [], // 나중에 EndScreen 에서 채워질 거예요
    );

    final endResult = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MediEndScreen(selectionData: endData),
      ),
    );

    // EndScreen이 true를 pop 했다면, MiddleScreen도 true로 pop
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
                  '복용 주기, 시작 날짜, 기간을 입력해주세요!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                const Text('복용 주기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              ],
            ),
          ),

          MediMiddleNextButton(onPressed: _onNext),
        ],
      ),
    );
  }
}
