import 'package:flutter/material.dart';
import 'package:medife/features/medication/MediMiddle.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medife/models/selection_data.dart';

class MediStart extends StatefulWidget {
  final SelectionData? selectionData;

  const MediStart({super.key, this.selectionData});

  @override
  State<MediStart> createState() => _MediStartState();
}

class _MediStartState extends State<MediStart> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _selectedNote;

  List<String> mockNotes = ['녹음 1', '녹음 2', '녹음 3'];

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          // 🔵 상단 헤더
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 12),
            color: const Color(0xFF7D8FF7),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
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
                const SizedBox(width: 48), // 오른쪽 공간 비워두기
              ],
            ),
          ),

          // 📋 입력 폼
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '약 이름이나 불편한 증상을 적어주세요.\n꼭 단어가 아니어도 괜찮아요.',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  const Text('이름 등록', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: '이름을 지어주세요! 예) 감기, 목이 아파(불편해서)/ 등',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('사진', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedImage != null
                                  ? '사진이 선택되었습니다'
                                  : '약 사진이 있다면 등록해주세요!',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                          const Icon(Icons.image_outlined),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('녹음하신 주의사항이 있다면 선택해주세요.', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedNote,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    hint: const Text('녹음 1'),
                    items: mockNotes.map((note) {
                      return DropdownMenuItem(
                        value: note,
                        child: Text(note),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNote = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // 🔘 하단 버튼
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                final updatedData = widget.selectionData?.copyWith(
                  medicineName: _nameController.text,
                  imagePath: _selectedImage?.path,
                  note: _selectedNote,
                ) ??
                    SelectionData(
                      medicineName: _nameController.text,
                      imagePath: _selectedImage?.path,
                      note: _selectedNote,
                    );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MediMiddle(selectionData: updatedData),
                  ),
                );
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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:medife/features/medication/MediMain.dart';
import 'package:medife/features/medication/MediEnd.dart';
import 'package:http_parser/http_parser.dart';

// RenewpoScreen -> MediStart

class MediStart extends StatefulWidget {
  SelectionData selectionData;

  MediStart({
    super.key,
    required this.selectionData
  });

  @override
  _MediStartState createState() => _MediStartState();
}

class _MediStartState extends State<MediStart> {
  List<TimeOfDay>? alarmTimesTemp;
  List<String>? alarmTimes;
  File? selectedImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 복용주기 개수만큼 알람시간을 추가하기
    alarmTimesTemp = List.generate(widget.selectionData.frequency!, (_) => const TimeOfDay(hour: 0, minute: 0));
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

  // 사진 선택 함수
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        print(selectedImage);
      });
    }
  }

  // 시간 변환 함수
  void changeTime(){
    // 정한 시간
    DateTime baseDate = DateTime.parse(widget.selectionData.startDate!);
    List<DateTime> dateTimeList = alarmTimesTemp!.map((time) {
      return
        DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          time.hour,
          time.minute,
        );
    }).toList();

    this.alarmTimes = dateTimeList.map((dateTime){
      String str = dateTime.toIso8601String();
      return
        str.split(".")[0]
      ;
    }).toList();
  }

  Future<void> _upload(SelectionData selectionData, BuildContext context) async {

    print("선택 결과 모음: $selectionData");



    final uri = Uri.parse('http://10.0.2.2:8080/api/medicines'); // ✅ 실제 주소로 수정
    var request = http.MultipartRequest("POST", uri);

    // ✅ 토큰 유효성검사
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null){
      print('토큰이 없습니다. 로그인이 필요합니다.');
      return;
    }
    // ✅ 헤더에 Authorization 추가
    request.headers['Authorization'] = 'Bearer $token';

    // ✅ JSON 데이터 추가
    Map<String, dynamic> jsonMap = {
      "name": selectionData.name,
      "characteristic": selectionData.characteristic,
      "startDate": selectionData.startDate,
      "duration": selectionData.duration,
      "frequency": selectionData.frequency,
      "imageUrl": selectionData.imageUrl,
      "prescribed": selectionData.prescribed,
      "dosageTimes": selectionData.dosageTimes,
      "alarmTimes": selectionData.alarmTimes
    };
    request.files.add(
      http.MultipartFile.fromString(
        'data',
        jsonEncode(jsonMap),
        contentType: MediaType('application', 'json'),
      ),
    );

    // ✅ 파일 추가
    if(selectedImage != null){
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          selectedImage!.path,
          contentType: MediaType('image', 'png'),
          filename: basename(selectedImage!.path),
        ),
      );
    }
    // ✅ 요청 보내기
    final response = await request.send();

    if (response.statusCode == 200) {
      print("✅ 업로드 성공!");
      final resStr = await response.stream.bytesToString();
      print(resStr);

      showConfirmDialogAndNavigate(context);
    } else {
      print("❌ 업로드 실패: ${response.statusCode}");
      print(response.headers);
      final responseBody = await response.stream.bytesToString(); // ✅ await 붙임
      print(responseBody);
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
          title: Text("확인"),
          content: Text("성공적으로 등록되었습니다"),
          actions: [
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기

                Navigator.of(context).popUntil((route) => route.settings.name == '/A');


              },
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 0),
                  const Text(
                    "마지막으로 알림을 원하는 시간을 등록해주세요!\n사진이 있다면 사진을 등록해도 좋아요.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // 알림 시간
                  const Text("알림 시간", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Column(
                    children: List.generate(alarmTimesTemp!.length, (index) {
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
                                    DateTime(2000, 1, 1, alarmTimesTemp![index].hour, alarmTimesTemp![index].minute),
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
                  const SizedBox(height: 20),

                  // 사진 업로드
                  const Text("사진", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: pickImage,
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
                          selectedImage == null
                              ? const Text("사진이 있다면 등록해주세요!", style: TextStyle(fontSize: 16, color: Colors.grey))
                              : const Text("사진 선택됨", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Icon(Icons.image, color: Colors.grey),
                        ],
                      ),
                    ),
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
                  bool result = await showConfirmDialog(context);
                  if (result){
                    // 선택한 시간을 문자열 리스트로 변환하는 함수 호출
                    changeTime();
                    _upload(widget.selectionData.copyWith(
                        imageUrl: "",
                        prescribed: true,
                        alarmTimes: alarmTimes
                    ), context);
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