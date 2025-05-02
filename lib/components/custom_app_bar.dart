import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF547EE8),
      padding: const EdgeInsets.only(top: 37, bottom: 12, left: 16, right: 16),
      child: SizedBox(
        height: 50,
        child: Stack(
          children: [
            // 가운데 텍스트 - 절대 중앙
            Positioned.fill(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // 왼쪽 아이콘
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // 오른쪽 아이콘
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}