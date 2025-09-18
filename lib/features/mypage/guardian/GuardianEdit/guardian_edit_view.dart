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
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,

      // ✅ 앱바 높이 줄이기
      appBar: const CustomAppBar(
        title: '보호자 알림 등록',
        height: 48,
      ),

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

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: CustomPrimaryButton(
            label: '저장',
            onPressed: onSave,
            margin: EdgeInsets.zero,
            backgroundColor: cs.primary,
            textStyle: tt.titleMedium?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
