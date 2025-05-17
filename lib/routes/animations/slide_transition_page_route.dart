import 'package:flutter/material.dart';

class SlideTransitionPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideTransitionPageRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 왼쪽에서 오른쪽으로 이동하는 애니메이션
      const begin = Offset(-1.0, 0.0); // 시작 위치: 왼쪽 끝
      const end = Offset.zero; // 끝 위치: 화면 중심
      const curve = Curves.easeInOut; // 애니메이션 곡선

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
