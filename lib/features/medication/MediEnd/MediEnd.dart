/*

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/features/medication/MediMain/MediMain.dart' as main_page;
import 'package:medife/features/medication/MediStart/MediStart.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';// kIsWeb 사용하려고 추가
// 파일 최상단에 추가
import 'package:path/path.dart';


class MediEnd extends StatefulWidget {
  SelectionData selectionData;

  MediEnd({
    super.key,
    required this.selectionData
  });

  @override
  _MediEndState createState() => _MediEndState();
}

class _MediEndState extends State<MediEnd> {
  List<TimeOfDay>? alarmTimesTemp;
  List<String> selectedDosageTimes = [];
  List<String>? alarmTimes;
  int? selectedFrequency;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 복용주기 개수만큼 알람시간을 추가하기
    bool isPrescribed = widget.selectionData.prescribed ?? false;

    if (isPrescribed) {
      // 특정일이면 아침/점심/저녁 복용 시간대 선택
      selectedDosageTimes = widget.selectionData.dosageTimes ?? [];
      alarmTimesTemp = List.generate(selectedDosageTimes.length, (_) => const TimeOfDay(hour: 8, minute: 0));
    } else {
      // 매일이면 복용 횟수
      selectedFrequency = widget.selectionData.frequency ?? 1;
      alarmTimesTemp = List.generate(selectedFrequency!, (_) => const TimeOfDay(hour: 8, minute: 0));
    }
  }

  // 시간 선택 함수
  Future<void> selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: alarmTimesTemp![index],
    );
    if (picked != null) {
      setState(() {
        alarmTimesTemp![index] = picked;
      });
    }
  }


  List<String> convertAlarmTimes() {
    final baseDate = DateTime.parse(widget.selectionData.startDate!);
    return alarmTimesTemp!.map((time) {
      final dateTime = DateTime(baseDate.year, baseDate.month, baseDate.day, time.hour, time.minute);
      return DateFormat('HH:mm:ss').format(dateTime);
    }).toList();
  }


  Future<void> _upload(BuildContext context) async {

    final uri = Uri.parse('http://localhost:8080/api/medicines'); // ✅ 실제 주소로 수정 final uri = Uri.parse('http://10.0.2.2:8080/api/medicines');
    var request = http.MultipartRequest("POST", uri);

    // ✅ 토큰 유효성검사
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    if (token == null){
      print('토큰이 없습니다. 로그인이 필요합니다.');
      return;
    }
    // ✅ 헤더에 Authorization 추가
    request.headers['Authorization'] = 'Bearer $token';

    bool isPrescribed = widget.selectionData.prescribed ?? false;
    alarmTimes = convertAlarmTimes();

    // ✅ JSON 데이터 추가
    final jsonMap = {
      "name": widget.selectionData.name,
      "characteristic": widget.selectionData.characteristic,
      "startDate": widget.selectionData.startDate,
      "duration": widget.selectionData.duration,
      "frequency": isPrescribed ? selectedDosageTimes.length : selectedFrequency,
      "imageUrl": "",
      "prescribed": isPrescribed,
      "dosageTimes": isPrescribed ? selectedDosageTimes : [],
      "alarmTimes": alarmTimes,
    };


    request.files.add(
      http.MultipartFile.fromString(
        'data',
        jsonEncode(jsonMap),
        contentType: MediaType('application', 'json'),
      ),
    );

    // ② 파일 파트 (선택된 이미지가 있으면)
    if (widget.selectionData.imageUrl != null &&
        widget.selectionData.imageUrl!.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          widget.selectionData.imageUrl!,      // 로컬 파일 경로
          contentType: MediaType('image', 'png'),
          filename: basename(widget.selectionData.imageUrl!),
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("등록 완료"),
          content: Text("성공적으로 등록되었습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => main_page.MediMain()),
                      (_) => false,
                );
              },
              child: Text("확인"),
            ),
          ],
        ),
      );
    } else {
      final res = await response.stream.bytesToString();
      print("업로드 실패: ${response.statusCode}\n$res");
    }
  }

  // 등록 확인 팝업창
  Future<bool> showConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("확인"),
          content: Text("등록하시겠습니까?"),
          actions: [
            TextButton(
              child: Text("취소"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("확인"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    return result == true;
  }
  // 약 등록 후 이동
  Future<void> showConfirmDialogAndNavigate(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // 바깥 터치로 닫히지 않게
      builder: (context) {
        return AlertDialog(
          title: Text("완료"),
          content: Text("성공적으로 등록되었습니다"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기

                // ✅ 모든 이전 페이지 지우고 메인으로 이동
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => main_page.MediMain()),
                      (route) => false,
                );
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    bool isPrescribed = widget.selectionData.prescribed ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // AppBar
          Container(
            color: Color(0xFF547EE8),
            padding: const EdgeInsets.only(top: 37, bottom: 12, left: 16, right: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: (){
                    Navigator.pop(context); // 현재 화면 종료 (이전 화면으로 돌아감)
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      '복약 알림 등록',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  SizedBox(height: 10),
                  Text(
                    isPrescribed
                        ? "마지막이에요! 복용 시간대와 알림 받을 시간을 선택해주세요."
                        : "마지막이에요! 하루에 약을 몇 번 드시나요? 알림 받을 시간을 선택해주세요.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  if (isPrescribed) ...[
                    Text("복용 시간대", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: ["아침", "점심", "저녁"].map((time) {
                        return FilterChip(
                          label: Text(time),
                          selected: selectedDosageTimes.contains(time),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedDosageTimes.add(time);
                                alarmTimesTemp!.add(TimeOfDay(hour: 8, minute: 0));
                              } else {
                                int index = selectedDosageTimes.indexOf(time);
                                selectedDosageTimes.removeAt(index);
                                alarmTimesTemp!.removeAt(index);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                  ] else ...[
                    Text("복용 주기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [1, 2, 3, 4].map((count) {
                        return Expanded(
                          child: RadioListTile<int>(
                            title: Text('$count회'),
                            value: count,
                            groupValue: selectedFrequency,
                            onChanged: (val) {
                              setState(() {
                                selectedFrequency = val!;
                                alarmTimesTemp = List.generate(val, (_) => TimeOfDay(hour: 8, minute: 0));
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                  ],
                  const Text("알림 시간", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Column(
                    children: List.generate(alarmTimesTemp!.length, (index) {
                      final time = alarmTimesTemp![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: GestureDetector(
                          onTap: () => selectTime(context, index),
                          child: Container(
                            height: 53,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('a hh:mm', 'ko_KR').format(
                                    DateTime(2000, 1, 1, time.hour, time.minute),
                                  ),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const Icon(Icons.access_time, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 등록 버튼
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: 358,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF547EE8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  // 최종 확인 팝업
                  bool confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext ctx) => AlertDialog(
                      title: Text("확인"),
                      content: Text("등록하시겠습니까?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text("취소"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text("확인"),
                        ),
                      ],
                    ),
                  ) ?? false;
                  if (confirm) {
                    await _upload(context);
                  }
                },
                child: const Text(
                  "등록",
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