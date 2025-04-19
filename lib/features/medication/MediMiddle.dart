import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/features/medication/MediEnd.dart';
import 'package:medife/models/selection_data.dart';

class MediMiddle extends StatefulWidget {
  final SelectionData selectionData;

  const MediMiddle({super.key, required this.selectionData});

  @override
  State<MediMiddle> createState() => _MediMiddleState();
}

class _MediMiddleState extends State<MediMiddle> {
  DateTime? _startDate;
  int _days = 1;

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 12),
            color: const Color(0xFF7D8FF7),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '복약 시작일과 복용 기간을 알려주세요.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  const Text('복약 시작일', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectStartDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _startDate != null ? DateFormat('yyyy년 MM월 dd일').format(_startDate!) : '복용 시작일을 선택해주세요.',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('복용 기간 (며칠 동안 복용하나요?)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            hintText: '예) 3',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _days = int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('일 동안')
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                if (_startDate != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MediEnd(
                        selectionData: widget.selectionData.copyWith(
                          startDate: _startDate,
                          days: _days,
                        ),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D8FF7),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('다음', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}


/*

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/features/medication/MediStart.dart';
import 'package:medife/features/medication/MediEnd.dart';
import 'package:medife/features/medication/MediMain.dart';

// RenewdayScreen -> MediMiddle


class MediMiddle extends StatefulWidget {

  SelectionData selectionData;

  MediMiddle({
    super.key,
    required this.selectionData
  });
  @override
  _RenewdayScreenState createState() => _RenewdayScreenState();
}

class _RenewdayScreenState extends State<MediMiddle> {
  int? selectedTime = 3;
  int? selectedPeriod = 3;
  TextEditingController customDaysController = TextEditingController();
  DateTime selectedDate = DateTime.now();

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
    // 복용 기간 일자와 실제 일수를 구분하여 버튼을 생성하기 위한 리스트
    final List<List<dynamic>> periods = [
      ["3일", 3],
      ["5일", 5],
      ["1개월", 30],
      ["1년", 365],
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Color(0xFF547EE8),
            padding: EdgeInsets.only(top: 37, bottom: 12, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: (){
                    Navigator.pop(context); // 현재 화면 종료 (이전 화면으로 돌아감)
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '복약 알림 등록',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  SizedBox(height: 20),
                  Text(
                    "복용 주기, 복용 시작 날짜, 기간을 입력해주세요!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text("복용 주기", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [1, 2, 3].map((time) {
                      return Row(
                        children: [
                          Radio(
                            value: time,
                            groupValue: selectedTime,
                            onChanged: (value) {
                              setState(() {
                                selectedTime = value as int;
                              });
                            },
                          ),
                          Text(time.toString(), style: TextStyle(fontSize: 14)),
                          SizedBox(width: 10),
                        ],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text("복용 시작 날짜", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${selectedDate.toLocal()}".split(' ')[0], style: TextStyle(fontSize: 16)),
                          Icon(Icons.edit, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("복용 기간", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Column(
                    children: periods.map((period) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Container(
                          width: 358,
                          height: 53,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: RadioListTile(
                            title: Text(period[0], style: TextStyle(fontSize: 20)),
                            value: period[1],
                            groupValue: selectedPeriod,
                            onChanged: (value) {

                              setState(() {
                                selectedPeriod = value as int;
                              });
                            },
                            activeColor: Colors.blue,
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: 358,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF547EE8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MediStart(
                        selectionData: widget.selectionData.copyWith( // 객체 속성에 이어서 값을 넣어 다음 페이지로 넘겨주기
                          startDate: DateFormat('yyyy-MM-dd').format(selectedDate),
                          duration: selectedPeriod,
                          frequency: selectedTime,
                          dosageTimes: ["아침", "점심", "저녁"],
                        )
                    )),
                  );
                },
                child: Text(
                  "다음",
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


 */