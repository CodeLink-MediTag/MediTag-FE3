import 'package:flutter/material.dart';

/// “레이블: 값” 형태로 한 줄에 가로 정렬해서 보여줌 예) “복용 시작 날짜: 2025-06-01”

class FieldRow extends StatelessWidget {
  final String label;
  final String value;

  const FieldRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
