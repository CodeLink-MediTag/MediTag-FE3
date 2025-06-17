import 'package:flutter/material.dart';
import 'package:medife/features/calendar/screen/calendar_screen.dart';

import '../../../../routes/route_names.dart';

class MediMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onCalendar;

  const MediMainAppBar({
    Key? key,
    required this.onBack,
    required this.onCalendar,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF547EE8),
      automaticallyImplyLeading: false,
      elevation: 0,
      title: const Text(
        '메인 화면',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 26,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        tooltip: '뒤로가기',
        onPressed: onBack,
      ),
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              tooltip: '달력 보기',
              onPressed: () {
                // Navigator.of(context).pushNamed(RouteName.calendar);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarScreen()),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
