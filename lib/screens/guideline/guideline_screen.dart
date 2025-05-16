import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/routes/route_names.dart';

class GuidelineScreen extends StatefulWidget {
  const GuidelineScreen({super.key});

  @override
  State<GuidelineScreen> createState() => _GuidelineScreenState();
}

class _GuidelineScreenState extends State<GuidelineScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> _images = [
    'assets/images/guideline_1.jpg',
    'assets/images/guideline_2.jpg',
    'assets/images/guideline_3.jpg',
  ];

  void _finishGuideline() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenGuideline', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteName.landing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _images.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _images[index],
                fit: BoxFit.cover,
              ),
              if (index == _images.length - 1)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _finishGuideline,
                      child: const Text("시작하기"),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
