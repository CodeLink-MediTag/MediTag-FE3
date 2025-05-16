import 'package:flutter/material.dart';

class MediMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onCalendar;

  const MediMainAppBar({
    Key? key,
    required this.onBack,
    required this.onCalendar,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF547EE8),
      elevation: 0,
      title: const Text('메인 화면', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: onCalendar,
        )
      ],
    );
  }
}


