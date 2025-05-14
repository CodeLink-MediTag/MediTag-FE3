import 'package:flutter/material.dart';

class MediStartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClose;
  const MediStartAppBar({Key? key, required this.onClose}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 28),
        onPressed: onClose,
      ),
      backgroundColor: const Color(0xFF7D9DFF),
      elevation: 0,
      title: const Text(
        '복약 알림 등록',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      centerTitle: true,
    );
  }
}
