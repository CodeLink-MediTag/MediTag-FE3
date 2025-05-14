/*


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/features/medication/MediStart/MediStart.dart';
import 'package:medife/features/medication/MediEnd/MediEnd.dart';


class MediMiddle extends StatefulWidget {
  final SelectionData selectionData;

  MediMiddle({
    super.key,
    required this.selectionData
  });

  @override
  _MediMiddleState createState() => _MediMiddleState();
}

class _MediMiddleState extends State<MediMiddle> {
  DateTime selectedDate = DateTime.now();
  int? selectedPeriod; // 1 = 특정일, 2 = 매일
  final TextEditingController customDaysController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FA),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF7D9DFF),
            padding: const EdgeInsets.only(
                top: 37, bottom: 12, left: 16, right: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      '복약 알림 등록',
                      style: TextStyle(fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  const Text(
                    "복용 주기, 시작 날짜, 기간을 입력해주세요!",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // 날짜 선택
                  const Text("복용 주기", style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<int>(
                          title: Text('특정일', style: TextStyle(fontSize: 16)),
                          value: 1,
                          groupValue: selectedPeriod,
                          onChanged: (value) {
                            setState(() {
                              selectedPeriod = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<int>(
                          title: Text('매일', style: TextStyle(fontSize: 16)),
                          value: 2,
                          groupValue: selectedPeriod,
                          onChanged: (value) {
                            setState(() {
                              selectedPeriod = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 복용 기간 타입 선택
                  const Text("복용 시작 날짜", style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('yyyy-MM-dd').format(selectedDate),
                              style: TextStyle(fontSize: 16)),
                          Icon(Icons.edit, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  if (selectedPeriod == 1) ...[
                    Text("며칠 동안 드시나요?", style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(
                      controller: customDaysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "예) 3",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius
                            .circular(10)),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // 다음 버튼
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: 358,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF547EE8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (selectedPeriod == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('복용 주기를 선택해주세요.')));
                    return;
                  }

                  int? days;
                  bool prescribed;

                  if (selectedPeriod == 1) {
                    days = int.tryParse(customDaysController.text);
                    if (days == null || days <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('복용 기간을 입력해주세요.')));
                      return;
                    }
                    prescribed = true;
                  } else {
                    days = 30; // 매일이면 기본 30일로 설정 (필요 시 수정)
                    prescribed = false;
                  }


                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MediEnd(
                            selectionData: widget.selectionData.copyWith(
                              startDate: DateFormat('yyyy-MM-dd').format(
                                  selectedDate),
                              duration: days,
                              frequency: 3,
                              // 기본 3으로 가정 (필요 시 수정)
                              dosageTimes: ["아침", "점심", "저녁"],
                              prescribed: prescribed,
                            ),
                          ),
                    ),
                  );
                },
                child: const Text(
                  "다음",
                  style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}



 */