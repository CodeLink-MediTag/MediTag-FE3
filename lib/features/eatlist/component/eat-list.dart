import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/features/eatlist/model/medicine.dart';
import 'package:medife/features/eatlist/repository/eat-list-repository.dart';
import 'package:shared_preferences/shared_preferences.dart';


// import '../../../routes/animations/slide_transition_page_route.dart';
import '../../../screens/landing.dart';
import 'eat-card.dart';

class EatList extends StatefulWidget {
  const EatList({super.key});

  @override
  _EatListState createState() => _EatListState();
}

class _EatListState extends State<EatList> {
  
  // 약 목록
  // 복용 상태
  List<Medicine> medicines = [];
  Map<int, Map<String, bool>> takenStatus = {};
  
  // 리포지토리
  EatListRepository eatListRepository = EatListRepository();

  @override
  void initState() {
    super.initState();
    initializeEatList();
  }

  Future<void> initializeEatList() async {
    try {
      String token = await getToken();
      List<Medicine> fetchedMedicines = await eatListRepository.fetchMedicines(
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
        token,
      );

      setState(() {
        medicines = fetchedMedicines;
        takenStatus = convertToTakenStatus(medicines);
      });
    } catch (e) {
      print("초기화 실패: $e");
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    try {
      if (accessToken == null) {
        throw Exception("토큰 없음");
      }
      return accessToken;
    } catch (e){
      throw e;
    }
  }

  String getTimeLabel(DateTime time, bool isPrescribed) {
    if (!isPrescribed) {
      // return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

      final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      return formatter.format(time);

    }

    if (time.hour == 8) return "아침";
    if (time.hour == 12) return "점심";
    if (time.hour == 18) return "저녁";
    return "${time.hour}:${time.minute}";
  }

  Map<int, Map<String, bool>> convertToTakenStatus(List<Medicine> medicines) {
    final Map<int, Map<String, bool>> takenStatus = {};

    for (final medicine in medicines) {
      final Map<String, bool> timeMap = {};

      for (final alarm in medicine.alarms) {
        final label = getTimeLabel(alarm.alarmTime, medicine.prescribed);
        timeMap[label] = alarm.taking;
      }

      takenStatus[medicine.medicineId] = timeMap;
    }

    return takenStatus;
  }


  Future<void> onTaken(
      int medicineId,
      String time,
      bool prescribed,
      ) async {
    final token = await getToken();

    setState(() {
      takenStatus[medicineId]![time] = true;
    });

    await eatListRepository.patchDosageTime(
      prescribed: prescribed,
      medicineId: medicineId,
      time: time,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      token: token,
    );
  }

  List<Widget> buildEatCards(
      List<Medicine> medicines,
      Map<int, Map<String, bool>> takenStatus,
      void Function(int medicineId, String time, bool prescribed) onTaken
      ) {
    return medicines.map((pill) {
      final times = takenStatus[pill.medicineId]!.keys.toList();

      return EatCard(
        prescribed: pill.prescribed,
        pillName: pill.name,
        times: times,
        takenMap: takenStatus[pill.medicineId]!,
        onTaken: (time) => onTaken(pill.medicineId, time, pill.prescribed),
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로 가기 시 Landing 화면으로 이동
        /*
        Navigator.push(
          context,
          SlideTransitionPageRoute(page: const Landing()), // 슬라이드 전환 애니메이션 적용
        );

         */
        return false; // 기본 동작인 pop을 방지
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ✅ 상단 AppBar 스타일
            Container(
              color: const Color(0xFF547EE8),
              padding: const EdgeInsets.only(top: 50, bottom: 16, left: 16, right: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {

                        Navigator.pop(context);

                        // 뒤로 가기 시 Landing 화면으로 이동
                        /*
                        Navigator.push(
                          context,
                          SlideTransitionPageRoute(page: const Landing()), // 슬라이드 전환
                        );

                         */
                      },
                    ),
                  ),
                  const Center(
                    child: Text(
                      '복용 기록',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                children: buildEatCards(medicines, takenStatus, onTaken),
              ),
            ),

            // const Spacer(),

          ],
        ),
      ),
    );
  }
}