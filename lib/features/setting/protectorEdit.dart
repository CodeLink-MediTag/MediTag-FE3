import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/features/setting/protectorAlert.dart';

class ProtectorEdit extends StatefulWidget {
  const ProtectorEdit({super.key});

  @override
  State<ProtectorEdit> createState() => _ProtectorEditState();
}

class _ProtectorEditState extends State<ProtectorEdit> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  String? selectedRelation;

  final List<String> relations = ['엄마', '아빠', '형제, 자매', '보호자'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = prefs.getString('guardianPhone') ?? '';
      selectedRelation = prefs.getString('guardianName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: const Color(0xFF7D8FF7),
            padding: const EdgeInsets.only(top: 50, bottom: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      '보호자 알림 등록',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
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
                    controller: _phoneController,
                    focusNode: _phoneFocus,
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
                    children: relations.map((relation) {
                      final isSelected = selectedRelation == relation;
                      return ChoiceChip(
                        label: Text(
                          relation,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF7D8FF7),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedRelation = relation;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('guardianPhone', _phoneController.text);
                await prefs.setString('guardianName', selectedRelation ?? '');
                await prefs.setString('userName', '김먀먀'); // 기본 사용자 이름

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProtectorAlert(
                      userName: '김먀먀',
                      phoneNumber: _phoneController.text,
                      guardianName: selectedRelation ?? '',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D8FF7),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '저장',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
