import 'package:flutter/material.dart';
import 'package:medife/features/mypage/guardian/guardian_api.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/components/custom_primary_button.dart';

class GuardianAlertView extends StatelessWidget {
  final bool loading;
  final List<GuardianResponse> guards;
  final Future<void> Function(int guardianId) onDelete;
  final VoidCallback onAddPressed;

  const GuardianAlertView({
    Key? key,
    required this.loading,
    required this.guards,
    required this.onDelete,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: '보호자 알림',
        onBack: () => Navigator.of(context).pop(),
        onHome: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/landing',
              (_) => false,
        ),
      ),

      // ★ 항상 목록 화면
      body: guards.isEmpty
      // 데이터가 없으면 '등록된 보호자가 없습니다.' 텍스트만
          ? const Center(child: Text('등록된 보호자가 없습니다.'))
      // 한 건이라도 있으면 카드 리스트
          : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: guards.length,
        itemBuilder: (ctx, i) {
          final g = guards[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text('${g.relationship} • ${g.phoneNumber}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(g.id),
              ),
            ),
          );
        },
      ),

      // ★ 항상 “추가” 버튼 노출
      bottomNavigationBar: CustomPrimaryButton(
        label: '보호자 알림 대상 추가',
        onPressed: onAddPressed,
      ),
    );
  }
}
