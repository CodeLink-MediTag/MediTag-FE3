import 'package:flutter/material.dart';
import 'package:medife/features/setting/protectorEdit.dart';
import 'package:medife/components/custom_app_bar.dart';

class ProtectorAlert extends StatelessWidget {
  final String userName; // ex: 김먀먀
  final String phoneNumber; // ex: 010-1234-5678
  final String guardianName; // ex: 엄마, 아빠 등

  const ProtectorAlert({
    super.key,
    required this.userName,
    required this.phoneNumber,
    required this.guardianName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomAppBar(title: '보호자 알림'), // ✅ 커스텀 앱바 사용

          // 본문
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '$userName님의 보호자',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '보호자 전화번호',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      phoneNumber,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '카카오톡으로 알림이 전송되고 있습니다.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProtectorEdit()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D8FF7),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '보호자 알림 대상 수정하기',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
