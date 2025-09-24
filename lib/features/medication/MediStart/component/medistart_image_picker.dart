// lib/features/medication/medistart/component/medistart_image_picker.dart

import 'dart:io';
import 'package:flutter/material.dart';

class MediStartImagePicker extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;
  const MediStartImagePicker({Key? key, required this.selectedImage, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool hasImage = selectedImage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진',
          style: theme.textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.cardColor, // 카드 색(라이트/다크에 안전)
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ← 썸네일 추가 (선택된 경우만)
                if (hasImage)
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image(
                          image: FileImage(selectedImage!),  // MediStart에선 로컬 파일만 옴
                          width: 32, height: 32, fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                Text(
                  hasImage ? '사진 선택됨' : '사진이 있다면 등록해주세요!',
                  style: hasImage
                      ? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                      : theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                ),
                Icon(Icons.image, color: theme.iconTheme.color),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
