import 'package:flutter/material.dart';

/// [medicine]의 이미지, 이름, 특징(Characteristic)을 카드 형태로 보여줌
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 이미지
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
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
                : const Icon(Icons.image, size: 35, color: Colors.grey),
          ),

          const SizedBox(width: 16),

          // 텍스트(이름 + 특징)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isPrescription ? '처방약입니다' : '일반약입니다',  // ← show here
                  style: TextStyle(
                    fontSize: 14,
                    color: isPrescription ? Colors.redAccent : Colors.green,
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
