// lib/features/medication/MediDetail/component/medidetail_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:medife/components/custom_primary_button.dart';
import '../../MediMain/model/medimain_medicine.dart';
import '../../MediEdit/screen/mediedit_screen.dart';

/// “주의사항 재생하기” 버튼과 “정보 수정” 버튼 (CustomPrimaryButton 사용)
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 공통 텍스트 스타일(테마 폰트 상속)
    final TextStyle primaryTextStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: cs.onPrimary,
    ) ??
        TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onPrimary);

    final TextStyle secondaryTextStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ) ??
        TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface);

    return Column(
      children: [
        // Primary 버튼
        CustomPrimaryButton(
          label: '주의사항 재생하기',
          onPressed: () {
            // TODO: 주의사항 재생 로직 추가
          },
          height: 48,
          borderRadius: 8,
          backgroundColor: cs.primary,
          textStyle: primaryTextStyle,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),

        const SizedBox(height: 12),

        // Secondary 버튼 (모양 같게 하되 색상은 surfaceVariant)
        CustomPrimaryButton(
          label: '정보 수정',
          onPressed: () {
            Navigator.push<Medicine>(
              context,
              MaterialPageRoute(builder: (_) => MediEditScreen(medicine: medicine)),
            ).then((updated) {
              if (updated != null) onEdited(updated);
            });
          },
          height: 48,
          borderRadius: 8,
          backgroundColor: cs.surfaceVariant,
          textStyle: secondaryTextStyle,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ],
    );
  }
}
