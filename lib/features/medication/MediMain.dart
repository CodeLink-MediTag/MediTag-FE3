import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/features/medication/MediStart/MediStart.dart';
import 'package:medife/models/selection_data.dart';
import 'package:medife/routes/animations/slide_transition_page_route.dart'; // 애니메이션을 위한 라우트 추가
import 'package:intl/intl.dart';
import 'package:medife/screens/landing.dart';

import 'MediStart/screen/medistart_screen.dart'; // 뒤로 갈 화면

class MediMain extends StatefulWidget {
  final SelectionData? selectionData;

  const MediMain({super.key, this.selectionData});

  @override
  State<MediMain> createState() => _MediMainState();
}

class _MediMainState extends State<MediMain> {
  Map<String, String> medicationTimes = {};
  Map<String, String> originalTimes = {};

  @override
  void initState() {
    super.initState();

    // SelectionData에서 알림 시간 정보를 바탕으로 초기 데이터 구성
    if (widget.selectionData != null) {
      for (String time in widget.selectionData!.selectedTimes ?? []) {
        String key = '${widget.selectionData!.medicineName}_$time';
        medicationTimes[key] = time;
      }
    } else {
      // 기본값 세팅 (없을 경우)
      medicationTimes = {
        '처방약_1': '오전 09:00',
        '처방약_2': '오후 02:00',
        '처방약_3': '오후 08:00',
        '비타민_1': '오전 09:00',
        '비타민_2': '오후 08:00',
      };
    }

    originalTimes.addAll(medicationTimes);
  }

  void toggleTime(String key) {
    setState(() {
      if (medicationTimes[key] == '복용 완료!') {
        medicationTimes[key] = originalTimes[key]!;
      } else {
        _showMedicationDialog(key);
      }
    });
  }

  void _confirmMedication(String key) {
    setState(() {
      medicationTimes[key] = '복용 완료!';
    });
  }

  void _showMedicationDialog(String key) {
    String currentTime = medicationTimes[key]!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 330,
            height: 210,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("복약 알림", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("$currentTime에 약을 드셨나요?", style: const TextStyle(fontSize: 19, color: Colors.grey)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF547EE8),
                        fixedSize: const Size(128, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        _confirmMedication(key);
                        Navigator.pop(context);
                      },
                      child: const Text("네", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        fixedSize: const Size(128, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("아니요", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로 가기 동작에 애니메이션 적용
        Navigator.push(
          context,
          SlideTransitionPageRoute(page: Landing()), // 뒤로 갈 화면에 애니메이션 적용
        );
        return false; // 기본 동작인 pop을 방지
      },
      child: Scaffold(
        body: Column(
          children: [
            const CustomAppBar(title: '복약 알림'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (widget.selectionData != null)
                      _buildMedicationCard(
                        widget.selectionData!.medicineName ?? '사용자 등록 약',
                        '사용자 등록 약',
                        widget.selectionData!.selectedTimes
                            ?.map((t) => '${widget.selectionData!.medicineName}_$t')
                            .toList() ?? [],
                      ),
                    if (widget.selectionData == null) ...[
                      _buildMedicationCard('처방약', '긴 상자', ['처방약_1', '처방약_2', '처방약_3']),
                      const SizedBox(height: 40),
                      _buildMedicationCard('비타민', '원형 긴 통', ['비타민_1', '비타민_2']),
                    ],
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF547EE8),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideTransitionPageRoute(page: MediStartScreen(selectionData: null)), // 애니메이션을 사용한 페이지 이동
                        );
                      },
                      child: const Text('알림 받을 약 추가', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(String title, String subtitle, List<String> timeKeys) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF547EE8), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image, color: Colors.grey, size: 35),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: timeKeys.map((key) => _buildTimeButton(key)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: medicationTimes[key] == '복용 완료!' ? const Color(0xFFA3BCF1) : Colors.white,
          minimumSize: const Size(110, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => toggleTime(key),
        child: Text(
          medicationTimes[key]!,
          style: TextStyle(
            fontSize: 14,
            color: medicationTimes[key] == '복용 완료!' ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
