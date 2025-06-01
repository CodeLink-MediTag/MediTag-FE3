import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/features/medication/MediEdit/component/mediedit_field.dart';

/// “시작 날짜 선택” 부분을 분리

class StartDateField extends StatelessWidget {
  final DateTime startDate;
  final VoidCallback onTap;

  const StartDateField({
    Key? key,
    required this.startDate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EditField(
      label: '복용 시작 날짜',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(DateFormat('yyyy-MM-dd').format(startDate)),
        trailing: const Icon(Icons.calendar_today),
        onTap: onTap,
      ),
    );
  }
}
