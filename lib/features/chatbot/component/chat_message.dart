import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Message extends StatelessWidget{
  // true이면 왼쪽 false면 오른쪽 정렬
  final bool alignLeft;
  // 메시지
  final String message;

  Message({
    super.key,
    this.alignLeft = true,
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    // alignLeft 기준으로 Alignment 프로퍼티 생성하기
    final alignment = alignLeft ? Alignment.centerLeft : Alignment.centerRight;
    // 챗봇 답변과 사용자 질문 배경 색 지정
    final bgColor = alignLeft ? Color(0xFF547EE8) : Color(0xFFDADADA);
    // 폰트 색
    final ftColor = alignLeft ? Colors.white : Colors.black;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ftColor
          ),
        ),
      ),
    );
  }
}