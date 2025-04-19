import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/features/medication/MediStart.dart';
import 'package:medife/models/selection_data.dart';

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
    return Scaffold(
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
                          .toList() ??
                          [],
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
                        MaterialPageRoute(builder: (_) => MediStart(selectionData: null)),
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



/*
import 'package:flutter/material.dart';
import 'package:medife/features/medication/MediStart.dart';
import 'package:medife/features/medication/MediDetail.dart';
import 'package:medife/features/calendar/calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/features/medication/MediEnd.dart';
import 'package:medife/features/sign/login.dart';
import 'package:medife/routes/route_observer.dart';

// Eatmed1 -> Medimain


class MediMain extends StatefulWidget {
  @override
  _MediMainState createState() => _MediMainState();
}

// Medicine 클래스: 약 정보를 담는 모델임
class Medicine {
  final String medicineName;    // 약 이름
  final String characteristic;   // 약 특징
  final String? imageUrl;       // 약 이미지 URL (null 가능)
  final bool prescribed;        // 처방약 여부
  final List<Alarm> alarms;     // 알람 목록

  Medicine({
    required this.medicineName,
    required this.characteristic,
    this.imageUrl,
    required this.prescribed,
    required this.alarms,
  });

  // JSON 데이터를 Medicine 객체로 변환하는 팩토리 생성자임
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medicineName: json['medicineName'],
      characteristic: json['characteristic'],
      imageUrl: json['imageUrl'],
      prescribed: json['prescribed'],
      alarms: (json['alarms'] as List)
          .map((alarm) => Alarm.fromJson(alarm))
          .toList(),
    );
  }

}

// Alarm 클래스: 약 복용 알람 정보를 담는 모델임
class Alarm {
  final DateTime alarmTime;  // 알람 시간
  bool taking;              // 복용 여부

  Alarm({
    required this.alarmTime,
    required this.taking,
  });

  // JSON 데이터를 Alarm 객체로 변환하는 팩토리 생성자임
  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      alarmTime: DateTime.parse(json['alarmTime']),
      taking: json['taking'],
    );
  }
}

class _MediMainState extends State<MediMain> with RouteAware{
  List<Medicine> medicines = [];  // 약 목록을 저장하는 리스트임
  bool isLoading = true;         // 로딩 상태를 나타내는 플래그임
  String currentDate = '';       // 현재 날짜를 저장하는 변수임
  String? token;                 // 인증 토큰을 저장하는 변수임

  @override
  void initState() {
    super.initState();
    _loadToken();  // 화면 초기화 시 토큰을 로드하는 함수 호출함
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 요게 B → A로 돌아올 때 호출됨
    print("A로 돌아왔습니다. 여기서 원하는 메서드 실행!");
    _loadToken();
  }

  // SharedPreferences에서 토큰을 로드하는 함수임
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    fetchMedicines();  // 토큰 로드 후 약 정보를 가져오는 함수 호출함
  }

  // 서버에서 약 정보를 가져오는 함수임
  Future<void> fetchMedicines() async {
    if (token == null) {
      print('토큰이 없습니다. 로그인이 필요합니다.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;  // 로딩 시작을 표시함
    });

    try {
      // 오늘 날짜를 yyyy-MM-dd 형식으로 포맷팅함
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      currentDate = today;

      // HTTP GET 요청을 보내 약 정보를 가져옴
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/medicines?date=$today'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // 응답 데이터를 파싱하여 Medicine 객체 리스트로 변환함
        final Map<String, dynamic> data = json.decode(response.body);
        List<Medicine> fetchedMedicines = (data['medicines'] as List)
            .map((medicine) => Medicine.fromJson(medicine))
            .toList();

        setState(() {
          medicines = fetchedMedicines;
          isLoading = false;  // 로딩 완료를 표시함
        });
      } else if (response.statusCode == 401) {
        // 토큰이 만료된 경우 처리 로직임
        print('토큰이 만료되었습니다. 다시 로그인해주세요.');
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load medicines: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching medicines: $e');
    }
  }

  // 약 복용 상태를 업데이트하는 함수임
  Future<void> updateMedicineTaking(Medicine medicine, Alarm alarm) async {
    if (token == null) {
      print('토큰이 없습니다. 로그인이 필요합니다.');
      return;
    }

    try {
      // HTTP POST 요청으로 복용 상태를 서버에 업데이트함
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/medicines/taking'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'medicineName': medicine.medicineName,
          'alarmTime': alarm.alarmTime.toIso8601String(),
          'taking': alarm.taking,
        }),
      );

      if (response.statusCode == 200) {
        print('약 복용 상태가 업데이트되었습니다.');
      } else {
        print('약 복용 상태 업데이트 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('약 복용 상태 업데이트 중 오류 발생: $e');
    }
  }

  // 약 복용 상태를 토글하는 함수임
  void _toggleTaking(Medicine medicine, Alarm alarm) {
    setState(() {
      alarm.taking = !alarm.taking;
    });
    // 서버에 복용 상태 업데이트를 요청함
    updateMedicineTaking(medicine, alarm);
  }

  void _showMedicationDialog(Medicine medicine, Alarm alarm) {
    String formattedTime = DateFormat('a hh:mm', 'ko_KR').format(alarm.alarmTime);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 330,
            height: 210,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(medicine.medicineName, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("$formattedTime에 약을 드셨나요?", style: TextStyle(fontSize: 19, color: Colors.grey)),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF547EE8),
                        fixedSize: Size(128, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        _toggleTaking(medicine, alarm);
                        Navigator.pop(context);
                      },
                      child: Text("네", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        fixedSize: Size(128, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("아니요", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black)),
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

    return Scaffold(
      body: Column(
        children: [
          // 앱바 대체용 Container
          Container(
            color: Color(0xFF547EE8),
            padding: EdgeInsets.only(top: 37, bottom: 12, left: 16, right: 16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: (){
                      Navigator.pop(context); // 현재 화면 종료 (이전 화면으로 돌아감)
                    },
                  ),
                  Text(
                    '메인 화면',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Calendar()),
                      );
                    },
                  )
                ]
            ),
          ),

          // 본문
          Expanded(
              child: Column(
                children: [
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : medicines.isEmpty
                      ? Center(
                      child: Text(
                          '등록된 약이 없습니다.',
                          style: TextStyle(fontSize: 18)
                      )
                  )
                      : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        ...medicines.map((medicine) => Column(
                          children: [
                            _buildMedicationCard(medicine),
                            SizedBox(height: 40),
                          ],
                        )).toList(),
                      ],
                    ),
                  ),

                  // 약 추가 버튼
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF547EE8),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MediEnd()),
                      );
                    },
                    child: Text('알림 받을 약 추가', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),

                ],
              )
          )
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medicine medicine) {
    print("imageUrl = ${medicine.imageUrl}");
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF547EE8), width: 2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
                child: medicine.imageUrl != null && medicine.imageUrl!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    medicine.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image, color: Colors.grey, size: 35);
                    },
                  ),
                )
                    : Icon(Icons.image, color: Colors.grey, size: 35),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medicine.medicineName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MediDetail()),
                      );
                    },
                  ),
                  SizedBox(height: 5),
                  Text(medicine.characteristic, style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: medicine.alarms.map((alarm) => _buildTimeButton(medicine, alarm)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(Medicine medicine, Alarm alarm) {
    String formattedTime = DateFormat('a hh:mm', 'ko_KR').format(alarm.alarmTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: alarm.taking ? Color(0xFFA3BCF1) : Colors.white,
          minimumSize: Size(110, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          if (alarm.taking) {
            _toggleTaking(medicine, alarm);
          } else {
            _showMedicationDialog(medicine, alarm);
          }
        },
        child: Text(
          alarm.taking ? '복용 완료!' : formattedTime,
          style: TextStyle(fontSize: 14, color: alarm.taking ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}


 */

