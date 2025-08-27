/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/ip/ip_address.dart';

import 'package:medife/components/custom_app_bar.dart';

class UnregisterScreen extends StatelessWidget {
  const UnregisterScreen({Key? key}) : super(key: key);

  Future<String?> _askPassword(BuildContext ctx) {
    final ctrl = TextEditingController();

    return showDialog<String>(
      context: ctx,
      barrierDismissible: false,
      builder: (dctx) {
        bool obscure = true;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('비밀번호 확인'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('탈퇴를 진행하려면 비밀번호를 다시 입력해주세요.'),
                  const SizedBox(height: 12),
                  // 디자인된 입력 박스
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F4), // 연한 회색
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 28, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            obscureText: obscure,
                            obscuringCharacter: '*',
                            autofocus: true,
                            textAlign: TextAlign.center, // 가운데 정렬
                            style: const TextStyle(letterSpacing: 6, fontSize: 18),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: '',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => obscure = !obscure),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dctx).pop(null), child: const Text('취소')),
                TextButton(onPressed: () => Navigator.of(dctx).pop(ctrl.text.trim()), child: const Text('확인')),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _showLoading(BuildContext ctx) {
    return showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _deleteAccount(BuildContext context, {String? password}) async {
    // 로딩 다이얼로그는 rootNavigator: true로 띄워서 안전하게 닫을 수 있게 함
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      useRootNavigator: true,
    );

    int statusCode = -1;
    String responseBody = '';

    try {
      final prefs = await SharedPreferences.getInstance();

      // 디버그: 저장된 키들 확인 (토큰 키가 다를 수 있으므로)
      debugPrint('prefs keys: ${prefs.getKeys()}');
      final token = prefs.getString('accessToken') ?? prefs.getString('token');
      debugPrint('token used: ${token != null ? "[REDACTED]" : "null"}');

      if (token == null || token.isEmpty) {
        // 반드시 로딩 닫기 전에 상태 처리
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증 정보가 없습니다. 다시 로그인해주세요.')),
        );
        if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
        return;
      }

      final uri = Uri.parse('http://$ipAddress:8080/api/member/me');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      debugPrint('DELETE -> $uri');
      debugPrint('Headers: $headers');
      debugPrint('Send password? ${password != null && password.isNotEmpty}');

      http.Response res;
      if (password != null && password.isNotEmpty) {
        final body = jsonEncode({'password': password});
        debugPrint('Request body: $body');
        res = await http.delete(uri, headers: headers, body: body);
      } else {
        res = await http.delete(uri, headers: headers);
      }

      statusCode = res.statusCode;
      responseBody = res.body ?? '';
      debugPrint('Response status: $statusCode');
      debugPrint('Response body: $responseBody');
    } catch (e, st) {
      debugPrint('Exception in _deleteAccount: $e');
      debugPrint(st.toString());
    } finally {
      // 항상 로딩 닫기 (rootNavigator 사용)
      try {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      } catch (_) {}
    }

    // 응답 처리 (로딩 닫힌 뒤)
    if (statusCode == 200 || statusCode == 204) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('정상적으로 탈퇴 처리되었습니다.')));
        // 탈퇴 성공하면 로그인 페이지로 이동
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
      return;
    }

    if (statusCode == 401 || statusCode == 403) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('인증이 필요합니다. 다시 로그인해주세요.')));
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
      return;
    }

    // 기타 오류: 서버 메시지 우선 보여주기
    String msg = '탈퇴 실패: ${statusCode < 0 ? '네트워크 오류' : statusCode}';
    try {
      if (responseBody.isNotEmpty) {
        final bodyJson = jsonDecode(responseBody);
        if (bodyJson is Map && bodyJson['message'] != null) {
          msg = '${bodyJson['message']} (code $statusCode)';
        } else {
          msg = responseBody;
        }
      }
    } catch (_) {
      // json 파싱 실패면 그대로 responseBody 사용(또는 기본 메시지)
      if (responseBody.isNotEmpty) msg = responseBody;
    }

    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onUnregisterPressed(BuildContext context) async {
    // 1) 최종 확인 다이얼로그
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

    // 2) (선택) 비밀번호 재확인 - 만약 서버에서 재인증을 요구한다면 필수
    final password = await _askPassword(context);
    if (password == null) {
      // 사용자가 취소함 -> 중단
      return;
    }

    // 3) 요청 수행
    await _deleteAccount(context, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: CustomAppBar(
          title: '회원 탈퇴',
          onBack: () => Navigator.of(context).pop(),
          onHome: () => Navigator.of(context).pushNamedAndRemoveUntil('/landing', (r) => false),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // ← 수평 중앙 정렬
            children: [
              const SizedBox(height: 12),
              const Text(
                '회원 탈퇴를 하시면 계정과 관련된 모든 데이터가 삭제됩니다.\n(일부 서비스는 법적 이유로 데이터 보관이 필요할 수 있습니다.)',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center, // ← 텍스트 가운데 정렬
              ),
              const SizedBox(height: 36),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  onPressed: () => _onUnregisterPressed(context),
                  child: const Text('계정 삭제(탈퇴)', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // 탈퇴 정책/복구 정책 링크로 이동하거나 설명을 보여줄 수 있음
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('탈퇴 안내'),
                      content: const Text('탈퇴 시 처리되는 항목, 데이터 보관 정책 설명'),
                      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인'))],
                    ),
                  );
                },
                child: const Text(
                  '탈퇴 시 처리 안내 보기',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

 */
