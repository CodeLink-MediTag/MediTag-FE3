import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class MediStartImagePicker extends StatelessWidget {
  final File? selectedImageFile;
  final Uint8List? selectedImageBytes;
  final VoidCallback onTap;

  const MediStartImagePicker({
    Key? key,
    this.selectedImageFile,
    this.selectedImageBytes,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final placeholder = Text(
      '사진이 있다면 등록해주세요!',
      style: TextStyle(fontSize: 16, color: Colors.grey),
    );
    Widget imagePreview;
    if (selectedImageFile != null) {
      imagePreview = Image.file(selectedImageFile!, width: 48, height: 48, fit: BoxFit.cover);
    } else if (selectedImageBytes != null) {
      imagePreview = Image.memory(selectedImageBytes!, width: 48, height: 48, fit: BoxFit.cover);
    } else {
      imagePreview = placeholder;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('사진', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(6), child: imagePreview),
                const Spacer(),
                const Icon(Icons.image, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
