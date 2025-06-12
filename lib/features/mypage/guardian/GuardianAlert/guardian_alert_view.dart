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
          '/landing',      // 홈 라우트에 맞게 수정
              (_) => false,
        ),
      ),

      body: guards.isEmpty
          ? const Center(child: Text('등록된 보호자가 없습니다.'))
          : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: guards.length,
        itemBuilder: (ctx, i) {
          final g = guards[i];
          return Card(
            color: Colors.grey.shade100, // 원하는 배경색
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              tileColor: Colors.grey.shade100, // (옵션) ListTile 전체에 색을 주고 싶을 때
              title: Text('${g.relationship} • ${g.phoneNumber}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(g.id),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomPrimaryButton(
        label: '보호자 알림 대상 추가',
        onPressed: onAddPressed,
      ),

    );
  }
}
