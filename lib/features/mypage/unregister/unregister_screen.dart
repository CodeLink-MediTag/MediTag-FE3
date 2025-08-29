// lib/features/mypage/unregister/unregister_screen.dart
import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/features/mypage/unregister/unregister_password_dialog.dart';
import 'package:medife/features/mypage/unregister/unregister_service.dart';
import 'package:medife/features/mypage/unregister/unregister_button.dart';

class UnregisterScreen extends StatelessWidget {
  const UnregisterScreen({Key? key}) : super(key: key);

  Future<void> _handleUnregister(BuildContext context) async {
    // 1. 최종 확인
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('계정을 완전히 삭제합니다. 복구할 수 없습니다.\n정말 탈퇴하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('탈퇴', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    // 2. 비밀번호 입력
    final password = await UnregisterPasswordDialog.show(context);
    if (password == null) return;

    // 3. 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      useRootNavigator: true,
    );

    // 4. 서비스 호출
    final result = await UnregisterService.deleteAccount(password: password);

    // 5. 로딩 닫기
    try {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (_) {}

    // 6. 결과 처리
    if (result.status == UnregisterStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('정상적으로 탈퇴 처리되었습니다.')));
      if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      return;
    }

    if (result.status == UnregisterStatus.unauthorized) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('인증이 필요합니다. 다시 로그인해주세요.')));
      if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      return;
    }

    final msg = result.message.isNotEmpty ? result.message : '탈퇴 실패: ${result.code}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: CustomAppBar(title: '회원 탈퇴'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              const Text(
                '회원 탈퇴를 하시면 계정과 관련된 모든 데이터가 삭제됩니다.\n(일부 서비스는 법적 이유로 데이터 보관이 필요할 수 있습니다.)',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              UnregisterButton(onPressed: () => _handleUnregister(context)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('탈퇴 안내'),
                    content: const Text('탈퇴 시 처리되는 항목, 데이터 보관 정책 설명'),
                    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인'))],
                  ),
                ),
                child: const Text('탈퇴 시 처리 안내 보기', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
