import 'package:flutter/material.dart';

class SlideTransitionPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideTransitionPageRoute({required this.page})
      : super(
    transitionDuration: const Duration(milliseconds: 300), // 애니메이션 속도 명시
    reverseTransitionDuration: const Duration(milliseconds: 300), // 뒤로가기 시 일관성 유지
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0); // 왼쪽에서 시작
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
