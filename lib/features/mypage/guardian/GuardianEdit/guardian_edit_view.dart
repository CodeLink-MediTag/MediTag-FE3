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
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: CustomAppBar(
        title: '보호자 알림 등록',
        onBack: () => Navigator.pop(context),
        // onHome: null,  // 홈 버튼을 숨기고 싶으면 여기서 null 처리
      ),

      body: Column(
        children: [
          // 본문 폼
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '약 복용 알림을 받을\n보호자의 정보를 입력해 주세요.\n\n나중에 수정이 가능해요.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '전화번호',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '숫자만 입력해주세요.',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '보호자',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: relations.map((rel) {
                      final selected = rel == selectedRelation;
                      return ChoiceChip(
                        label: Text(
                          rel,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: selected,
                        selectedColor: const Color(0xFF7D8FF7),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (_) => onRelationChanged(rel),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          CustomPrimaryButton(
            label: '저장',
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}
