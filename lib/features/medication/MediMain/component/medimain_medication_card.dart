import 'package:flutter/material.dart';
import 'package:medife/features/medication/MediDetail/screen/medidetail_screen.dart';
import 'package:medife/features/medication/MediMain/model/medimain_medicine.dart';
import 'package:medife/features/medication/MediMain/model/medimain_alarm.dart';
import 'dart:io';

class MedicationCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onToggleFavorite;
  final void Function(Alarm) onToggleTaking;
  final void Function(Alarm) onAskConfirm;
  final ValueChanged<Medicine> onEdited;

  const MedicationCard({
    Key? key,
    required this.medicine,
    required this.onToggleFavorite,
    required this.onToggleTaking,
    required this.onAskConfirm,
    required this.onEdited,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // card background: theme.cardColor (main.dart에서 설정한 값)
    final Color cardBg = theme.cardColor;
    // border uses primary color for emphasis (brand)
    final Color borderColor = cs.primary;
    // shadow color: theme.shadowColor with small opacity
    final Color shadowColor = theme.shadowColor.withOpacity(0.08);
    // placeholder/icon color
    final Color placeholderIconColor = theme.iconTheme.color?.withOpacity(0.7) ?? cs.onSurface.withOpacity(0.7);
    // subtitle color
    final Color subtitleColor = cs.onSurface.withOpacity(0.75);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 이미지 박스: surfaceVariant 사용 -> 다크/라이트 자동 대응
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: (medicine.imageUrl != null && medicine.imageUrl!.isNotEmpty)
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                  image: resolveImage(medicine.imageUrl),  // <-- 여기!
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.broken_image,
                      size: 32, color: theme.iconTheme.color?.withOpacity(0.7)),
                ),
                )
                    : Icon(Icons.image, size: 32, color: placeholderIconColor),
              ),
              const SizedBox(width: 12),
              // 타이틀 + 서브타이틀
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이름: theme 텍스트 스타일 기반으로 덮어쓰기
                    Text(
                      medicine.medicineName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine.prescribed ? '처방약' : '일반약',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              // 즐겨찾기 (star)
              IconButton(
                icon: Icon(
                  medicine.isFavorite ? Icons.star : Icons.star_border,
                  color: medicine.isFavorite ? Colors.amber : theme.iconTheme.color,
                ),
                onPressed: onToggleFavorite,
              ),
              // 상세페이지 이동
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
                onPressed: () {
                  Navigator.push<Medicine>(
                    context,
                    MaterialPageRoute(builder: (_) => MediDetailScreen(medicine: medicine)),
                  ).then((updated) {
                    if (updated != null) onEdited(updated);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 알람 시간 캡슐(태그)
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: medicine.alarms.map((alarm) {
                final formatted = TimeOfDay.fromDateTime(alarm.alarmTime).format(context);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant, // 다크/라이트 대응
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: shadowColor, blurRadius: 2, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: Text(
                    formatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  ImageProvider<Object> resolveImage(String? src) {
    if (src == null || src.isEmpty) {
      return const AssetImage('assets/images/placeholder.png'); // 없으면 임시 에셋으로
    }
    final s = src.trim();
    if (s.startsWith('http://') || s.startsWith('https://')) {
      return NetworkImage(s);        // 서버 URL
    }
    return FileImage(File(s));       // 그 외는 로컬 파일 경로
  }
}
