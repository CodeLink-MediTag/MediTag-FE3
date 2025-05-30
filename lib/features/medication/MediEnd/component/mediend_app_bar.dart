import 'package:flutter/material.dart';

class MediEndAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const MediEndAppBar({
    Key? key,
    this.title = '복약 알림 등록',
    this.onBack,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF547EE8),
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 26,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        tooltip: '뒤로가기',
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
      elevation: 0,
    );
  }
}
