import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EatList extends StatefulWidget {
  const EatList({super.key});

  @override
  _EatListState createState() => _EatListState();
}

class _EatListState extends State<EatList> {
  Map<String, bool> takenMap = {
    "아침": false,
    "점심": false,
    "저녁": false,
    "비타민": false,
  };

  String getTodayDateFormatted() {
    final now = DateTime.now();
    return DateFormat('yyyy년 M월 d일', 'ko_KR').format(now);
  }

  String getTitleText() {
    if (takenMap.values.every((v) => v)) {
      return '${getTodayDateFormatted()} 복용 완료 했습니다!';
    } else {
      return '${getTodayDateFormatted()} 복용 기록 입니다';
    }
  }

  String getButtonText(String key) {
    return takenMap[key]!
        ? '${key}약 복용 완료 !'
        : key;
  }

  Color getButtonColor(String key) {
    return takenMap[key]!
        ? const Color(0xFFF4B7E8) // 분홍색
        : const Color(0xFF547EE8); // 파란색
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ✅ 상단 AppBar 스타일 (제목 중앙 + 뒤로가기 아이콘)
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
          Text(
            getTitleText(),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          // ✅ 버튼 리스트
          ...takenMap.keys.map((key) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    takenMap[key] = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: getButtonColor(key),
                  minimumSize: const Size(double.infinity, 65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  getButtonText(key),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            );
          }).toList(),

          const Spacer(),

          // ✅ 하단 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: ElevatedButton(
              onPressed: () {
                // TODO: 달력에서 날짜 확인하기 기능
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF547EE8),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '달력에서 다른 날짜 확인하기',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
