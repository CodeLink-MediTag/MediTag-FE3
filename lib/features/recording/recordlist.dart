import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart'; // 커스텀 앱바 import

class RecordList extends StatelessWidget {
  const RecordList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          const CustomAppBar(title: '주의사항 녹음 목록'), // ✅ 커스텀 앱바 사용

          const SizedBox(height: 12),

          // 🔊 녹음 카드
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFD2E0FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    '녹음1',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('2024년 12월 03일'),
                  trailing: const Text('1:01'),
                ),
                const Divider(height: 1, color: Colors.white),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          // ▶️ 재생 기능 구현 예정
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          // 🗑 삭제 기능 구현 예정
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF7D8FF7),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        ),
                        child: const Text(
                          '삭제',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
