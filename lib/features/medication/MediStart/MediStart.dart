/*

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medife/features/medication/MediMiddle/MediMiddle.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MediStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
      MediMain();
  }
}

// 선택 데이터들을 수집하기 위해 필요한 클래스
class SelectionData{
  String? name;
  String? characteristic;
  String? startDate;
  int? duration;
  int? frequency;
  String? imageUrl;
  bool? prescribed;
  List<String>? dosageTimes;
  List<String>? alarmTimes;

  SelectionData({
    this.name,
    this.characteristic,
    this.startDate,
    this.duration,
    this.frequency,
    this.imageUrl,
    this.prescribed,
    this.dosageTimes,
    this.alarmTimes
  });
  SelectionData copyWith({
    String? name,
    String? characteristic,
    String? startDate,
    int? duration,
    int? frequency,
    String? imageUrl,
    bool? prescribed,
    List<String>? dosageTimes,
    List<String>? alarmTimes,
  }){
    return SelectionData(
        name: name ?? this.name,
        characteristic: characteristic ?? this.characteristic,
        startDate: startDate ?? this.startDate,
        duration: duration ?? this.duration,
        frequency: frequency ?? this.frequency,
        imageUrl: imageUrl ?? this.imageUrl,
        prescribed: prescribed ?? this.prescribed,
        dosageTimes: dosageTimes?? this.dosageTimes,
        alarmTimes: alarmTimes ?? this.alarmTimes
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return "SelectionData(name: $name,"
        " characteristic: $characteristic,"
        " startDate: $startDate,"
        " duration: $duration,"
        " frequency: $frequency,"
        " imageUrl: $imageUrl,"
        " prescribed: $prescribed,"
        " dosageTimes: $dosageTimes,"
        " alarmTimes: $alarmTimes";
  }
}
class MediMain extends StatefulWidget {
  @override
  _MediMainState createState() => _MediMainState();
}


class _MediMainState extends State<MediMain> {

  // 텍스트 입력값 가져오기 위한 컨트롤러
  final TextEditingController medicineName = TextEditingController();
  File? selectedImage;
  List<String> recordings = ['녹음 1', '녹음 2', '녹음 3'];
  String? selectedRecording;

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F5FA),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: Color(0xFF7D9DFF),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '복약 알림 등록',
                        style: TextStyle(
                          fontSize: 22,
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

            // 본문
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("약 이름이나 불편하신 증상을 적어주세요.\n꼭 단어가 아니어도 괜찮아요.",
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 28),

                    Text("약 이름 등록", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(
                      controller: medicineName,
                      decoration: InputDecoration(
                        hintText: "이름을 지어주세요! 예) 감기, 목감기, 두통 등",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 24),

                    Text("사진", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade400),
                        ),
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
                    SizedBox(height: 24),

                    Text("녹음하신 주의사항이 있다면 선택해주세요.", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedRecording,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      hint: Text("녹음 1"),
                      onChanged: (value) {
                        setState(() {
                          selectedRecording = value!;
                        });
                      },
                      items: recordings.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 48),
                  ],
                ),
              ),
            ),

            // 다음 버튼
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7D9DFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final name = medicineName.text;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MediMiddle(
                          selectionData: SelectionData(
                            name: name,




                            characteristic: selectedRecording,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "다음",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


 */