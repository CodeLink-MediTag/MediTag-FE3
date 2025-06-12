import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/features/mypage/guardian/GuardianEdit/guardian_edit_view.dart';
import 'package:medife/features/mypage/guardian/GuardianAlert/guardian_alert_container.dart';
import 'package:medife/features/mypage/guardian/guardian_api.dart';

class GuardianEdit extends StatefulWidget {
  const GuardianEdit({Key? key}) : super(key: key);

  @override
  State<GuardianEdit> createState() => _GuardianEditState();
}

class _GuardianEditState extends State<GuardianEdit> {
  final _phoneController = TextEditingController();
  String? _selectedRelation;
  final _api = GuardianApi();
  bool _loading = true;

  static const _relations = ['엄마', '아빠', '형제, 자매', '보호자'];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = prefs.getString('guardianPhone') ?? '';
      _selectedRelation   = prefs.getString('guardianName');
      _loading            = false;
    });
  }

  Future<void> _onSave() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null || _selectedRelation == null) return;

    final created = await _api.register(
      token,
      _phoneController.text.trim(),
      _selectedRelation!,
    );

    // 로컬에도 저장
    await prefs.setString('guardianPhone',   created.phoneNumber);
    await prefs.setString('guardianName',    created.relationship);

    // 이 화면을 대체하며 알림 리스트로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GuardianAlert()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return GuardianEditView(
      phoneController:    _phoneController,
      relations:          _relations,
      selectedRelation:   _selectedRelation,
      onRelationChanged:  (r) => setState(() => _selectedRelation = r),
      onSave:             _onSave,
    );
  }
}
