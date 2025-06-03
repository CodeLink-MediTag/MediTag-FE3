import 'package:flutter/material.dart';
import '../../MediMain/model/medimain_medicine.dart';
import '../../MediEdit/screen/mediedit_screen.dart';

/// “주의사항 재생하기” 버튼과 “정보 수정” 버튼을 모아둠
class MediDetailActions extends StatelessWidget {
  final Medicine medicine;
  final ValueChanged<Medicine> onEdited;

  const MediDetailActions({
    Key? key,
    required this.medicine,
    required this.onEdited,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // TODO: 주의사항 재생 로직이 필요하면 여기에 추가
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('주의사항 재생하기'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            // MediEdit로 이동
            Navigator.push<Medicine>(
              context,
              MaterialPageRoute(builder: (_) => MediEditScreen(medicine: medicine)),
            ).then((updated) {
              if (updated != null) {
                onEdited(updated);
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('정보 수정'),
        ),
      ],
    );
  }
}
