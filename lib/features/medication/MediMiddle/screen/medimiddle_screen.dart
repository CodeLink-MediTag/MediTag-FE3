// lib/features/medication/MediMiddle/screen/medimiddle_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:medife/features/medication/MediStart/model/medistart_selection_data.dart';
import 'package:medife/features/medication/MediEnd/model/mediend_selection_data.dart';
import 'package:medife/features/medication/MediEnd/screen/mediend_screen.dart';

import '../component/medimiddle_period_selector.dart';
import '../component/medimiddle_date_picker.dart';
import '../component/medimiddle_duration_input.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/components/custom_primary_button.dart';

class MediMiddleScreen extends StatefulWidget {
  final MediStartSelectionData selectionData;
  const MediMiddleScreen({Key? key, required this.selectionData}) : super(key: key);

  @override
  _MediMiddleScreenState createState() => _MediMiddleScreenState();
}

class _MediMiddleScreenState extends State<MediMiddleScreen> {
  DateTime selectedDate = DateTime.now();
  int? selectedPeriod; // 1=특정일, 2=매일
  final TextEditingController customDaysController = TextEditingController();

  // 새로 추가한 변수: 처방약 체크 여부
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
    if (selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('복용 기간을 선택해주세요.', style: Theme.of(context).textTheme.bodyMedium)),
      );
      return;
    }

    late int days;
    if (selectedPeriod == 1) {
      final parsed = int.tryParse(customDaysController.text);
      if (parsed == null || parsed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('복용 기간을 올바르게 입력해주세요.', style: Theme.of(context).textTheme.bodyMedium)),
        );
        return;
      }
      days = parsed;
    } else {
      days = 30;
    }

    final prescribed = _isPrescribed;

    final mid = widget.selectionData;
    final endData = MediEndSelectionData(
      name: mid.name,
      characteristic: mid.characteristic,
      startDate: DateFormat('yyyy-MM-dd').format(selectedDate),
      duration: days,
      frequency: prescribed ? 3 : 0, // 처방약이면 3회, 아니면 0
      imageUrl: mid.imageUrl,
      prescribed: prescribed,
      dosageTimes: prescribed ? ['아침', '점심', '저녁'] : [],
      alarmTimes: [], // EndScreen에서 채움
    );

    final bool? endResult = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MediEndScreen(selectionData: endData)),
    );

    if (endResult == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    customDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      // 테마 기반 배경
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppBar(
          title: '복용 기간/시작일 설정',
          onBack: () => Navigator.of(context).pop(),
          onHome: () {
            Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
          },
        ),
      ),

      // body: ListView (스크롤 가능)
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // 헤딩 텍스트들: theme 사용
                Text(
                  '복용 기간, 시작 날짜를 입력해주세요!',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 20),

                Text('복용 기간', style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                MediMiddlePeriodSelector(
                  selectedPeriod: selectedPeriod,
                  onChanged: (v) => setState(() => selectedPeriod = v),
                ),

                const SizedBox(height: 20),
                Text('복용 시작 날짜', style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                MediMiddleDatePicker(selectedDate: selectedDate, onTap: _selectDate),

                const SizedBox(height: 28),
                MediMiddleDurationInput(
                  visible: selectedPeriod == 1,
                  controller: customDaysController,
                ),

                const SizedBox(height: 20),
                // 체크박스 항목: 텍스트 스타일과 체크 색상 theme 기반
                CheckboxListTile(
                  title: Text('처방약인가요?', style: theme.textTheme.bodyLarge),
                  value: _isPrescribed,
                  onChanged: (v) => setState(() => _isPrescribed = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: cs.primary,
                  checkColor: cs.onPrimary,
                ),
              ],
            ),
          ),

          // 하단 버튼: SafeArea로 감싸기 (홈바 충돌 방지)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: CustomPrimaryButton(
                label: '다음',
                onPressed: _onNext,
                margin: EdgeInsets.zero,        // 외부 margin 은 여기서
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // backgroundColor은 CustomPrimaryButton 내부에서 theme로 받도록 구현되었다면 생략 가능.
                // 만약 CustomPrimaryButton이 기본색을 하드코딩하고 있다면,
                // backgroundColor: cs.primary, 를 추가해서 테마 색을 쓸 수 있음.
              ),
            ),
          ),
        ],
      ),
    );
  }
}
