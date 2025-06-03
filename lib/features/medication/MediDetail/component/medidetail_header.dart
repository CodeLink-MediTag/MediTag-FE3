import 'package:flutter/material.dart';

/// [medicine]의 이미지, 이름, 특징(Characteristic)을 카드 형태로 보여줌
class MediDetailHeader extends StatelessWidget {
  final String imageUrl;
  final String medicineName;
  final String characteristic;

  const MediDetailHeader({
    Key? key,
    required this.imageUrl,
    required this.medicineName,
    required this.characteristic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF547EE8), width: 2),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
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
                  characteristic,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
