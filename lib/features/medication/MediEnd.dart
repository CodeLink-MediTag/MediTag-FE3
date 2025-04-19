import 'package:flutter/material.dart';
import 'package:medife/features/medication/MediMain.dart';
import 'package:medife/models/selection_data.dart';

class MediEnd extends StatefulWidget {
  final SelectionData selectionData;

  const MediEnd({super.key, required this.selectionData});

  @override
  State<MediEnd> createState() => _MediEndState();
}

class _MediEndState extends State<MediEnd> {
  String selectedTimeGroup = '아침';
  List<String> timeOptions = ['아침 8:00', '점심 1:00', '저녁 7:00', '아무때나'];
  List<String> selectedTimes = [];

  void toggleTime(String time) {
    setState(() {
      if (selectedTimes.contains(time)) {
        selectedTimes.remove(time);
      } else {
        selectedTimes.add(time);
      }
    });
  }

  Future<void> _addCustomTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );

    if (picked != null) {
      final String formatted = picked.format(context);
      setState(() {
        selectedTimes.add(formatted);
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

          // 본문
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '마지막이에요!\n복용 시간대와 알림 받을 시간을 선택 해주세요.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  const Text('복용 시간대', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['아침', '점심', '저녁'].map((label) {
                      return Row(
                        children: [
                          Radio<String>(
                            value: label,
                            groupValue: selectedTimeGroup,
                            onChanged: (value) {
                              setState(() {
                                selectedTimeGroup = value!;
                              });
                            },
                            activeColor: const Color(0xFF7D8FF7),
                          ),
                          Text(label),
                        ],
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  const Text('알림 시간', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ...timeOptions.map((time) => _buildTimeButton(time)),
                      _buildAddTimeButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 등록 버튼
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                SelectionData finalData = widget.selectionData.copyWith(
                  timeGroup: selectedTimeGroup,
                  selectedTimes: selectedTimes,
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MediMain(selectionData: finalData),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D8FF7),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('등록', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String time) {
    final bool isSelected = selectedTimes.contains(time);
    return GestureDetector(
      onTap: () => toggleTime(time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7D8FF7) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF7D8FF7)),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAddTimeButton() {
    return GestureDetector(
      onTap: _addCustomTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF7D8FF7)),
        ),
        child: const Text(
          '+ 시간 추가',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'package:medife/features/medication/MediMain.dart';
import 'package:medife/features/medication/MediMiddle.dart';

// renew -> MediEnd

class MediEnd extends StatelessWidget {
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
class Eatmed1 extends StatefulWidget {
  @override
  _Eatmed1State createState() => _Eatmed1State();
}

class _Eatmed1State extends State<Eatmed1> {

  // 텍스트 입력값 가져오기 위한 컨트롤러
  final TextEditingController medicineName = TextEditingController();
  final TextEditingController characteristic = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // AppBar
          Container(
            color: Color(0xFF547EE8),
            padding: EdgeInsets.only(top: 37, bottom: 12, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
              crossAxisAlignment: CrossAxisAlignment.center, // 아이콘과 텍스트 수직 중앙 정렬
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: (){
                    Navigator.pop(context); // 현재 화면 종료 (이전 화면으로 돌아감)
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '복약 알림 등록',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // 텍스트 색상 흰색
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40), // 오른쪽 여백
              ],
            ),
          ),

          // 나머지 화면
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30), // 여백 조정
                  Text(
                    "약의 이름과 특징을 입력해 주세요!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30), // 여백 추가

                  // 이름 등록
                  Text("이름 등록", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 358,
                    height: 48,
                    child: TextField(
                      controller: medicineName, // 약 이름 입력값 가져오기
                      decoration: InputDecoration(
                        hintText: "이름을 지어주세요! 예) 처방약, 비타민B",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // 특징 등록
                  Text("특징 등록", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 358,
                    height: 48,
                    child: TextField(
                      controller: characteristic, // 특징 입력값 가져오기
                      decoration: InputDecoration(
                        hintText: "특징을 등록해 주세요! 예) 동그란 통, 사각 통",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),

                  Spacer(), // 버튼을 아래로 밀어줌

                  // 버튼들
                  Column(
                    children: [
                      SizedBox(
                        width: 358,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF547EE8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {},
                          child: Text(
                            "처방약 등록",
                            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 358,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF547EE8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: (){
                            // 입력받은 값 가져와서 객체에 담아 다음 페이지로 넘겨주기
                            final medicineNameInput = medicineName.text;
                            final characteristicInput = characteristic.text;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MediMiddle(
                                selectionData: SelectionData(
                                    name: medicineNameInput,
                                    characteristic: characteristicInput
                                ),
                              )),
                            );
                          },
                          child: Text(
                            "다음",
                            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // 마지막 여백 추가
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


 */