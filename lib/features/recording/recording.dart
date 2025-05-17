import 'package:flutter/material.dart';
import 'package:medife/features/recording/recordlist.dart';
import 'package:medife/features/recording/recording_pop.dart'; // 녹음 화면 import
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/routes/animations/slide_transition_page_route.dart'; // 슬라이드 애니메이션 경로
import 'package:medife/screens/landing.dart'; // 뒤로 갈 화면

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로 가기 동작에 애니메이션 적용
        Navigator.push(
          context,
          SlideTransitionPageRoute(page: Landing()), // 뒤로 갈 화면에 애니메이션 적용
        );
        return false; // 기본 동작인 pop을 방지
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomAppBar(
                title: '주의사항 녹음',
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🎙 녹음 하기 버튼 → 녹음 화면으로 이동
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            SlideTransitionPageRoute(page: const RecordingPop()), // 애니메이션 적용된 페이지 전환
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF547EE8),
                          minimumSize: const Size(double.infinity, 200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('🎙 녹음 하기'),
                      ),
                      const SizedBox(height: 30),

                      // 📁 녹음 목록 가기 버튼
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            SlideTransitionPageRoute(page: const RecordList()), // 애니메이션 적용된 페이지 전환
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF547EE8),
                          minimumSize: const Size(double.infinity, 200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('📁 녹음 목록 가기'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}