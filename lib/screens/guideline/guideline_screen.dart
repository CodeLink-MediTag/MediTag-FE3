import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/screens/landing.dart';

class GuidelineScreen extends StatefulWidget {
  const GuidelineScreen({super.key});

  @override
  State<GuidelineScreen> createState() => _GuidelineScreenState();
}

class _GuidelineScreenState extends State<GuidelineScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _showButtons = false;

  final List<String> _images = [
    'assets/images/guideline_1.jpg',
    'assets/images/guideline_2.jpg',
    'assets/images/guideline_3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ _controller 리스너 제거, onPageChanged로 대체
  }

  Future<void> _setGuidelineSeen(bool neverShowAgain) async {
    final prefs = await SharedPreferences.getInstance();
    // neverShowAgain == true: 다시 보지 않기, false: 닫기
    await prefs.setBool('hasSeenGuideline', neverShowAgain);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Landing()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _showButtons = index == _images.length - 1; // ✅ 마지막 페이지에서 버튼 표시
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                _images[index],
                fit: BoxFit.cover,
              );
            },
          ),
          if (_showButtons)
            Positioned(
              bottom: 60,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _setGuidelineSeen(true), // 다시 보지 않기
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('다시 보지 않기', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _setGuidelineSeen(false), // 닫기
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('닫기', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
