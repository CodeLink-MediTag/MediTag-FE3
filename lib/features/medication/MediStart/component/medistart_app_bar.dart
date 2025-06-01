import 'package:flutter/material.dart';

class MediStartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClose;
  const MediStartAppBar({Key? key, required this.onClose}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF547EE8),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        '복약 알림 등록',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 28),
        onPressed: onClose,
      ),
    );
  }
}
