import 'package:flutter/material.dart';
import 'package:medife/features/medication/MediDetail/MediDetail.dart';
import 'package:medife/features/medication/MediMain/model/medimain_medicine.dart';
import 'package:medife/features/medication/MediMain/model/medimain_alarm.dart';
import 'package:medife/features/medication/MediMain/component/medimain_time_button.dart';


class MedicationCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onToggleFavorite;
  final void Function(Alarm) onToggleTaking;
  final void Function(Alarm) onAskConfirm;

  const MedicationCard({
    Key? key,
    required this.medicine,
    required this.onToggleFavorite,
    required this.onToggleTaking,
    required this.onAskConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF547EE8), width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 이미지
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: medicine.imageUrl != null && medicine.imageUrl!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(medicine.imageUrl!, fit: BoxFit.cover),
                )
                    : const Icon(Icons.image, size: 32, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medicine.medicineName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(medicine.characteristic, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
              // 즐겨찾기
              IconButton(
                icon: Icon(
                  medicine.isFavorite ? Icons.star : Icons.star_border,
                  color: medicine.isFavorite ? Colors.yellow : Colors.grey,
                ),
                onPressed: onToggleFavorite,
              ),
              // 상세페이지 이동
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MediDetail(medicine: medicine)),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),
          // 알람 버튼들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: medicine.alarms.map((alarm) {
                return TimeButton(
                  medicine: medicine,
                  alarm: alarm,
                  onToggleTaking:  () => onToggleTaking(alarm),
                  onAskConfirm:    () => onAskConfirm(alarm),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
