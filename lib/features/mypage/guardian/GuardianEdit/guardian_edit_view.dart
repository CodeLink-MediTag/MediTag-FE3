import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/components/custom_primary_button.dart';

class GuardianEditView extends StatelessWidget {
  final TextEditingController phoneController;
  final List<String> relations;
  final String? selectedRelation;
  final ValueChanged<String> onRelationChanged;
  final VoidCallback onSave;

  const GuardianEditView({
    Key? key,
    required this.phoneController,
    required this.relations,
    required this.selectedRelation,
    required this.onRelationChanged,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final cs = theme.colorScheme;

    return Scaffold(
      // 키보드 올라올 때 자동으로 화면 크기 재계산 (기본 true이지만 명시)
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: '보호자 알림 등록',
        onBack: () => Navigator.pop(context),
      ),

      // body 를 스크롤 가능하게 하고, viewInsets.bottom(=키보드 높이) 만큼 패딩 추가
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '약 복용 알림을 받을\n보호자의 정보를 입력해 주세요.\n\n나중에 수정이 가능해요.',
                        style: tt.bodyLarge,
                      ),
                      const SizedBox(height: 24),

                      Text('전화번호', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),

                      // 전화번호 입력 필드
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: tt.bodyMedium,
                        decoration: InputDecoration(
                          hintText: '숫자만 입력해주세요.',
                          filled: true,
                          fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text('보호자', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),

                      // 선택칩
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: relations.map((rel) {
                          final selected = rel == selectedRelation;
                          return ChoiceChip(
                            label: Text(
                              rel,
                              style: selected
                                  ? tt.bodyMedium?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600)
                                  : tt.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                            ),
                            selected: selected,
                            selectedColor: cs.primary,
                            backgroundColor: theme.cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (_) => onRelationChanged(rel),
                          );
                        }).toList(),
                      ),

                      // 빈 공간을 채워서 버튼이 바닥에 붙게 만듦 (IntrinsicHeight + Expanded 유사 동작)
                      const SizedBox(height: 16),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),

      // 저장 버튼은 bottomNavigationBar에 두어 키보드 위로 표시되게 함
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: CustomPrimaryButton(
            label: '저장',
            onPressed: onSave,
            margin: EdgeInsets.zero,
            // CustomPrimaryButton이 textStyle/backgroundColor 파라미터를 받는다면 theme 값 전달
            backgroundColor: cs.primary,
            textStyle: tt.titleMedium?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
