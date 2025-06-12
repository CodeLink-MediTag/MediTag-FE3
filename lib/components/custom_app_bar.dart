import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onHome;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBack,
    this.onHome,
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
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        tooltip: '뒤로가기',
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          tooltip: '홈으로 가기',
          onPressed: onHome ?? () {
            Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
          },
        ),
      ],
    );
  }
}

