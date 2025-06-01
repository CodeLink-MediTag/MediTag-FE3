// lib/features/medication/MediEdit/component/mediedit_imagepicker_field.dart
import 'dart:io';
import 'package:flutter/material.dart';

/// ‘이미지 선택’ 버튼과, 선택된 이미지(썸네일)를 함께 보여줌

class ImagePickerField extends StatelessWidget {
  final File? pickedImage;
  final VoidCallback onPickImage;

  const ImagePickerField({
    Key? key,
    required this.pickedImage,
    required this.onPickImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: onPickImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('이미지 선택'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.black,
          ),
        ),
        const SizedBox(width: 12),
        if (pickedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              pickedImage!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}
