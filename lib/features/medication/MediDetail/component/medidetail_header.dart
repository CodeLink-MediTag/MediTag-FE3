// lib/features/medication/MediDetail/component/medidetail_header.dart
import 'package:flutter/material.dart';

class MediDetailHeader extends StatelessWidget {
  final String imageUrl;
  final String medicineName;
  final bool isPrescription;

  const MediDetailHeader({
    Key? key,
    required this.imageUrl,
    required this.medicineName,
    required this.isPrescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // placeholder / image container background
    final Color imageBg = cs.surfaceVariant;
    // placeholder icon color (아이콘은 theme.iconTheme 이용)
    final Color placeholderIconColor = theme.iconTheme.color?.withOpacity(0.7) ?? cs.onSurface.withOpacity(0.7);
    // title color
    final Color titleColor = cs.onSurface;
    // prescription badge color: error (red) or secondary (green-ish) — theme에 맞추기
    final Color badgeColor = isPrescription ? cs.error : cs.secondary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 이미지
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: imageBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: (imageUrl.isNotEmpty)
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            )
                : Icon(Icons.image, size: 35, color: placeholderIconColor),
          ),

          const SizedBox(width: 16),

          // 텍스트(이름 + 특징)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPrescription ? '처방약입니다' : '일반약입니다',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
