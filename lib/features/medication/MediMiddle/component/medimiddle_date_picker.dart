import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MediMiddleDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const MediMiddleDatePicker({
    Key? key,
    required this.selectedDate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(10),
          color: theme.cardColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('yyyy-MM-dd').format(selectedDate),
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
            ),
            Icon(Icons.edit, color: theme.iconTheme.color),
          ],
        ),
      ),
    );
  }
}
