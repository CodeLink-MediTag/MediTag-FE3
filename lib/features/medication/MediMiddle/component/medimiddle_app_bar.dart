import 'package:flutter/material.dart';

class MediMiddleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;

  const MediMiddleAppBar({Key? key, this.onBack}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF547EE8),
      automaticallyImplyLeading: false,
      title: const Text(
        '복약 알림 등록',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 26,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      elevation: 0,
    );
  }
}
