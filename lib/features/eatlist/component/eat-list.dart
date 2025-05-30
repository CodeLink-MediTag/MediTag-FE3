import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/features/eatlist/model/medicine.dart';
import 'package:medife/features/eatlist/repository/eat-list-repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'eat-card.dart';
import 'package:medife/components/custom_app_bar.dart'; // 커스텀 앱바 경로 맞게 수정

class EatList extends StatefulWidget {
  const EatList({super.key});

  @override
  _EatListState createState() => _EatListState();
}

class _EatListState extends State<EatList> {

  List<Medicine> medicines = [];
  Map<int, Map<String, bool>> takenStatus = {};

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
        // 뒤로 가기 막고 직접 처리하거나 그대로 pop 허용 가능
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: '복용 기록',
          onBack: () {
            Navigator.pop(context);
          },
          // 필요하면 onHome 콜백 추가 가능
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 30), // 앱바 밑 공간 조정
          child: ListView(
            children: buildEatCards(medicines, takenStatus, onTaken),
          ),
        ),
      ),
    );
  }
}
