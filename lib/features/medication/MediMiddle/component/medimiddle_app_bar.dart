import 'package:flutter/material.dart';

class MediMiddleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MediMiddleAppBar({Key? key, this.title = '복약 알림 등록'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF7D9DFF),
      title: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 25);
}