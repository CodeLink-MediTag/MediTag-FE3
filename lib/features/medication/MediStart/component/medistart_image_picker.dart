import 'dart:io';
import 'package:flutter/material.dart';

class MediStartImagePicker extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;
  const MediStartImagePicker({Key? key, required this.selectedImage, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사진',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                selectedImage == null
                    ? const Text('사진이 있다면 등록해주세요!', style: TextStyle(fontSize: 16, color: Colors.grey))
                    : const Text('사진 선택됨', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Icon(Icons.image, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
